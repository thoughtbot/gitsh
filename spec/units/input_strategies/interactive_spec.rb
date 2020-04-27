require 'spec_helper'
require 'gitsh/input_strategies/interactive'

describe Gitsh::InputStrategies::Interactive do
  before do
    register_env(fetch: '')
    register_line_editor
    register_repo

    stub_file_runner
    stub_history
    stub_terminal
  end

  describe '#setup' do
    it 'loads the history' do
      described_class.new.setup

      expect(Gitsh::History).to have_received(:load)
    end

    it 'sets up the line editor' do
      described_class.new.setup

      expect(registered_line_editor).to have_received(:completion_proc=)
    end

    it 'loads the ~/.gitshrc file' do
      described_class.new.setup

      expect(Gitsh::FileRunner).to have_received(:run).
        with(hash_including(path: "#{ENV['HOME']}/.gitshrc"))
    end

    it 'handles parse errors in the ~/.gitshrc file' do
      allow(Gitsh::FileRunner).
        to receive(:run).and_raise(Gitsh::ParseError, 'my message')

      described_class.new.setup

      expect(registered_env).to have_received(:puts_error).with('gitsh: my message')
    end
  end

  describe '#teardown' do
    it 'saves the history' do
      register_env(fetch: '')
      input_strategy = described_class.new

      input_strategy.teardown

      expect(Gitsh::History).to have_received(:save)
    end
  end

  describe '#read_command' do
    it 'returns the user input' do
      input_strategy = described_class.new
      allow(registered_line_editor).to receive(:readline).and_return('user input')
      input_strategy.setup

      expect(input_strategy.read_command).to eq 'user input'
    end

    it 'returns the default command when the user input is blank' do
      input_strategy = described_class.new
      allow(registered_line_editor).to receive(:readline).and_return(' ')
      set_registered_env_value('gitsh.defaultCommand', 'my default command')
      input_strategy.setup

      expect(input_strategy.read_command).to eq 'my default command'
    end

    it 'handles a SIGINT by retrying' do
      input_strategy = described_class.new
      line_editor_results = StubbedMethodResult.new.
        raises(Interrupt).
        returns('user input after interrupt')
      allow(registered_line_editor).to receive(:readline) { line_editor_results.next_result }

      input_strategy.setup
      expect(input_strategy.read_command).to eq 'user input after interrupt'
    end

    it 'handles a SIGWINCH' do
      line_editor = SignallingLineEditor.new('WINCH')
      allow(line_editor).to receive(:set_screen_size)
      register(line_editor: line_editor)
      input_strategy = described_class.new

      input_strategy.setup
      expect { input_strategy.read_command }.not_to raise_exception
      expect(line_editor).to have_received(:set_screen_size).with(24, 80)
    end

    it 'handles a SIGWINCH when the terminal size cannot be determined' do
      line_editor = SignallingLineEditor.new('WINCH')
      allow(line_editor).to receive(:set_screen_size)
      register(line_editor: line_editor)
      allow(Gitsh::Terminal).to receive(:size).and_raise(
        Gitsh::Terminal::UnknownSizeError,
        'Unknown terminal size',
      )
      input_strategy = described_class.new

      input_strategy.setup
      expect { input_strategy.read_command }.not_to raise_exception
      expect(line_editor).not_to have_received(:set_screen_size)
    end
  end

  describe '#read_continuation' do
    it 'returns the user input' do
      input_strategy = described_class.new
      allow(registered_line_editor).to receive(:readline).and_return('user input')
      input_strategy.setup

      expect(input_strategy.read_continuation).to eq 'user input'
      expect(registered_line_editor).to have_received(:readline).
        with(described_class::CONTINUATION_PROMPT, true)
    end

    it 'handles a SIGINT by returning nil' do
      input_strategy = described_class.new
      allow(registered_line_editor).to receive(:readline).and_raise(Interrupt)
      input_strategy.setup

      expect(input_strategy.read_continuation).to be_nil
    end
  end

  describe '#handle_parse_error' do
    it 'outputs the error' do
      input_strategy = described_class.new

      input_strategy.handle_parse_error('my message')

      expect(registered_env).to have_received(:puts_error).with('gitsh: my message')
    end
  end

  def stub_file_runner
    allow(Gitsh::FileRunner).to receive(:run)
  end

  def stub_history
    allow(Gitsh::History).to receive(:load)
    allow(Gitsh::History).to receive(:save)
  end

  def stub_terminal
    allow(Gitsh::Terminal).to receive(:color_support?).and_return(true)
    allow(Gitsh::Terminal).to receive(:size).and_return([24, 80])
  end
end
