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

    it 'sets up readline' do
      runner = build_interactive_runner
      runner.run

      expect(readline).to have_received(:completion_append_character=)
      expect(readline).to have_received(:completion_proc=)
    end

    it 'loads the ~/.gitshrc file' do
      runner = build_interactive_runner

      runner.run

      expect(script_runner).to have_received(:run).
        with("#{ENV['HOME']}/.gitshrc")
    end

    it 'handles a SIGINT' do
      runner = build_interactive_runner
      readline_results = StubbedMethodResult.new.
        returns('a').
        raises(Interrupt).
        returns('b').
        raises(SystemExit)
      allow(readline).to receive(:readline) { readline_results.next_result }

      begin
        runner.run
      rescue SystemExit
      end

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with('a')
      expect(interpreter).to have_received(:execute).with('b')
    end

    it 'handles a SIGWINCH' do
      readline = SignallingReadline.new('WINCH')
      allow(readline).to receive(:set_screen_size)
      runner = build_interactive_runner(readline: readline)

      expect { runner.run }.not_to raise_exception
      expect(readline).to have_received(:set_screen_size).with(24, 80)
    end
  end

  def build_interactive_runner(options={})
    Gitsh::InteractiveRunner.new(
      interpreter: interpreter,
      readline: options.fetch(:readline, readline),
      history: history,
      env: env,
      terminal: terminal,
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

  def readline
    @readline ||= spy('readline', {
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
    double('terminal', color_support?: true, lines: 24, cols: 80)
  end
end
