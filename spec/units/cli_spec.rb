require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
    context 'with valid arguments and no script file' do
      it 'calls the interactive runner' do
        interactive_runner = stub('InteractiveRunner', run: nil)
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
        script_runner = stub('ScriptRunner', run: nil)
        interactive_runner = stub('InteractiveRunner', run: nil)
        cli = Gitsh::CLI.new(
          args: [],
          script_runner: script_runner,
          interactive_runner: interactive_runner,
          env: stub('Environment', tty?: false),
        )

        cli.run

        expect(script_runner).to have_received(:run).with('-')
        expect(interactive_runner).to have_received(:run).never
      end
    end

    context 'with a script file' do
      it 'calls the script runner with the script file' do
        script_runner = stub('ScriptRunner', run: nil)
        interactive_runner = stub('InteractiveRunner', run: nil)
        cli = Gitsh::CLI.new(
          args: ['path/to/a/script'],
          script_runner: script_runner,
          interactive_runner: interactive_runner
        )

        cli.run

        expect(script_runner).to have_received(:run).with('path/to/a/script')
        expect(interactive_runner).to have_received(:run).never
      end
    end

    context 'with invalid arguments' do
      it 'exits with a usage message' do
        env = stub('Environment', puts_error: nil)
        cli = Gitsh::CLI.new(args: %w( --bad-argument ), env: env)

        expect { cli.run }.to raise_exception(SystemExit)
      end
    end
  end
end
