require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Source do
  it_behaves_like "an internal command"

  describe "#execute" do
    context "with a valid file" do
      it "executes the script_runner and returns true" do
        env = stub('env')
        script_runner = stub('ScriptRunner', run: nil)
        Gitsh::ScriptRunner.stubs(:new).returns(script_runner)
        command = described_class.new(env, 'source', arguments('/path'))

        result = command.execute

        expect(Gitsh::ScriptRunner).to have_received(:new).with(env: env)
        expect(script_runner).to have_received(:run).with('/path')
        expect(result).to eq true
      end
    end

    context "with no file argument" do
      it "prints a usage message and returns false" do
        env = stub('env', puts_error: nil)
        command = described_class.new(env, 'source', arguments())

        result = command.execute

        expect(env).to have_received(:puts_error).with('usage: :source path')
        expect(result).to eq false
      end
    end
  end
end
