require 'spec_helper'
require 'gitsh/interactive_runner'

describe Gitsh::InteractiveRunner do
  describe '#run' do
    it 'loads the history' do
      runner = build_interactive_runner
      runner.run

      expect(history).to have_received(:load)
    end

    it 'saves the history' do
      runner = build_interactive_runner
      runner.run

      expect(history).to have_received(:save)
    end

    it 'sets up the line editor' do
      runner = build_interactive_runner
      runner.run

      expect(line_editor).to have_received(:completion_proc=)
    end

    it 'loads the ~/.gitshrc file' do
      runner = build_interactive_runner

      runner.run

      expect(script_runner).to have_received(:run).
        with("#{ENV['HOME']}/.gitshrc")
    end

    it 'handles a SIGINT' do
      runner = build_interactive_runner
      line_editor_results = StubbedMethodResult.new.
        returns('a').
        raises(Interrupt).
        returns('b').
        raises(SystemExit)
      allow(line_editor).to receive(:readline) { line_editor_results.next_result }

      begin
        runner.run
      rescue SystemExit
      end

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with('a')
      expect(interpreter).to have_received(:execute).with('b')
    end

    it 'handles a SIGWINCH' do
      line_editor = SignallingLineEditor.new('WINCH')
      allow(line_editor).to receive(:set_screen_size)
      runner = build_interactive_runner(line_editor: line_editor)

      expect { runner.run }.not_to raise_exception
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
      runner = build_interactive_runner(readline: line_editor, terminal: terminal)

      expect { runner.run }.not_to raise_exception
      expect(line_editor).not_to have_received(:set_screen_size)
    end
  end

  def build_interactive_runner(options={})
    Gitsh::InteractiveRunner.new(
      interpreter: interpreter,
      line_editor: options.fetch(:line_editor, line_editor),
      history: history,
      env: env,
      terminal: options.fetch(:terminal, terminal),
      script_runner: script_runner,
    )
  end

  def script_runner
    @script_runner ||= spy('script_runner', run: nil)
  end

  def interpreter
    @interpreter ||= spy('interpreter', execute: nil)
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
      repo_initialized?: false,
      repo_config_color: '',
      fetch: '',
      :[] => nil
    })
  end

  def terminal
    double('terminal', color_support?: true, size: [24, 80])
  end
end
