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

    it 'handles a SIGINT' do
      runner = build_interactive_runner

      readline.stubs(:readline).
        returns('a').
        then.raises(Interrupt).
        then.returns('b').
        then.raises(SystemExit)

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
      readline.stubs(:set_screen_size)
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
      term_info: term_info
    )
  end

  def interpreter
    @interpreter ||= stub('interpreter', execute: nil)
  end

  def history
    @history ||= stub('history', load: nil, save: nil)
  end

  def readline
    @readline ||= stub('readline', {
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil,
      readline: nil
    })
  end

  def env
    @env ||= stub('Environment', {
      print: nil,
      puts: nil,
      repo_initialized?: false,
      fetch: '',
      :[] => nil
    })
  end

  def term_info
    stub('term_info', color_support?: true, lines: 24, cols: 80)
  end
end
