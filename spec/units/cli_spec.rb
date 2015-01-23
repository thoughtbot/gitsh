require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
    context 'with valid arguments and no script file' do
      it 'calls the interactive runner' do
        interactive_runner = double('InteractiveRunner', run: nil)
        cli = Gitsh::CLI.new(
          args: [],
          interactive_runner: interactive_runner
        )

        cli.run

        expect(interactive_runner).to have_received(:run)
      end
    end

    context 'when STDIN is not a TTY' do
      it 'calls the script runner with -' do
        script_runner = double('ScriptRunner', run: nil)
        interactive_runner = double('InteractiveRunner', run: nil)
        cli = Gitsh::CLI.new(
          args: [],
          script_runner: script_runner,
          interactive_runner: interactive_runner,
          env: double('Environment', tty?: false),
        )

        cli.run

        expect(script_runner).to have_received(:run).with('-')
        expect(interactive_runner).not_to have_received(:run)
      end
    end

    context 'with a script file' do
      it 'calls the script runner with the script file' do
        script_runner = double('ScriptRunner', run: nil)
        interactive_runner = double('InteractiveRunner', run: nil)
        cli = Gitsh::CLI.new(
          args: ['path/to/a/script'],
          script_runner: script_runner,
          interactive_runner: interactive_runner
        )

        cli.run

        expect(script_runner).to have_received(:run).with('path/to/a/script')
        expect(interactive_runner).not_to have_received(:run)
      end
    end

    context 'with an unreadable script file' do
      it 'exits' do
        env = double('env', puts_error: nil)
        script_runner = double('ScriptRunner')
        allow(script_runner).to receive(:run).
          and_raise(Gitsh::NoInputError, 'Oh no!')
        interactive_runner = double('InteractiveRunner')
        cli = Gitsh::CLI.new(
          env: env,
          args: ['path/to/a/script'],
          script_runner: script_runner,
          interactive_runner: interactive_runner,
        )

        expect { cli.run }.to raise_exception(SystemExit)
        expect(env).to have_received(:puts_error).with('gitsh: Oh no!')
      end
    end

    context 'with invalid arguments' do
      it 'exits with a usage message' do
        env = double('Environment', puts_error: nil)
        cli = Gitsh::CLI.new(args: %w( --bad-argument ), env: env)

        expect { cli.run }.to raise_exception(SystemExit)
      end
    end
  end
end
