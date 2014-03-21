require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
    context 'with valid arguments' do
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

    context 'with invalid arguments' do
      it 'exits with a usage message' do
        env = stub('Environment', puts_error: nil)
        cli = Gitsh::CLI.new(args: %w( --bad-argument ), env: env)

        expect { cli.run }.to raise_exception(SystemExit)
      end
    end
  end
end
