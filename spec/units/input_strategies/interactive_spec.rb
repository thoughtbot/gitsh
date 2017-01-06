require 'spec_helper'
require 'gitsh/input_strategies/interactive'

describe Gitsh::InputStrategies::Interactive do
  before { stub_file_runner }

  describe '#setup' do
    it 'loads the history' do
      input_strategy = build_input_strategy

      input_strategy.setup

      expect(history).to have_received(:load)
    end

    it 'sets up the line editor' do
      input_strategy = build_input_strategy

      input_strategy.setup

      expect(line_editor).to have_received(:completion_proc=)
    end

    it 'loads the ~/.gitshrc file' do
      input_strategy = build_input_strategy

      input_strategy.setup

      expect(Gitsh::FileRunner).to have_received(:run).
        with(hash_including(path: "#{ENV['HOME']}/.gitshrc"))
    end
  end

  describe '#teardown' do
    it 'saves the history' do
      input_strategy = build_input_strategy

      input_strategy.teardown

      expect(history).to have_received(:save)
    end
  end

  describe '#read_command' do
    it 'returns the user input' do
      input_strategy = build_input_strategy
      allow(line_editor).to receive(:readline).and_return('user input')
      input_strategy.setup

      expect(input_strategy.read_command).to eq 'user input'
    end

    it 'returns the default command when the user input is blank' do
      input_strategy = build_input_strategy
      allow(line_editor).to receive(:readline).and_return(' ')
      allow(env).to receive(:fetch).with('gitsh.defaultCommand').
        and_return('my default command')
      input_strategy.setup

      expect(input_strategy.read_command).to eq 'my default command'
    end

    it 'handles a SIGINT' do
      input_strategy = build_input_strategy
      line_editor_results = StubbedMethodResult.new.
        raises(Interrupt).
        returns('user input after interrupt')
      allow(line_editor).to receive(:readline) { line_editor_results.next_result }

      input_strategy.setup
      expect(input_strategy.read_command).to eq 'user input after interrupt'
    end

    it 'handles a SIGWINCH' do
      line_editor = SignallingLineEditor.new('WINCH')
      allow(line_editor).to receive(:set_screen_size)
      input_strategy = build_input_strategy(line_editor: line_editor)

      input_strategy.setup
      expect { input_strategy.read_command }.not_to raise_exception
      expect(line_editor).to have_received(:set_screen_size).with(24, 80)
    end

    it 'handles a SIGWINCH when the terminal size cannot be determined' do
      line_editor = SignallingLineEditor.new('WINCH')
      allow(line_editor).to receive(:set_screen_size)
      terminal = double('Terminal', color_support?: true)
      allow(terminal).to receive(:size).and_raise(
        Gitsh::Terminal::UnknownSizeError,
        'Unknown terminal size',
      )
      input_strategy = build_input_strategy(readline: line_editor, terminal: terminal)

      input_strategy.setup
      expect { input_strategy.read_command }.not_to raise_exception
      expect(line_editor).not_to have_received(:set_screen_size)
    end
  end

  def build_input_strategy(options={})
    described_class.new(
      line_editor: options.fetch(:line_editor, line_editor),
      history: history,
      env: env,
      terminal: options.fetch(:terminal, terminal),
    )
  end

  def stub_file_runner
    allow(Gitsh::FileRunner).to receive(:run)
  end

  def history
    @history ||= spy('history', load: nil, save: nil)
  end

  def line_editor
    @line_editor ||= spy('LineEditor', {
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil,
      readline: nil
    })
  end

  def env
    @env ||= double('Environment', {
      print: nil,
      puts: nil,
      repo_config_color: '',
      fetch: '',
      :[] => nil
    })
  end

  def terminal
    double('terminal', color_support?: true, size: [24, 80])
  end
end
