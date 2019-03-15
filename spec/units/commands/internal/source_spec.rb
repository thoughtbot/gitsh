require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Source do
  it_behaves_like "an internal command"

  describe "#execute" do
    context "with a valid file" do
      it "calls the FileRunner and returns true" do
        env = double('env')
        allow(Gitsh::FileRunner).to receive(:run)
        command = described_class.new('source', ['/path'])

        result = command.execute(env)

        expect(Gitsh::FileRunner).to have_received(:run).
          with(env: env, path: '/path')
        expect(result).to eq true
      end
    end

    context "with no file argument" do
      it "prints a usage message and returns false" do
        env = spy('env', puts_error: nil)
        command = described_class.new('source', [])

        result = command.execute(env)

        expect(env).to have_received(:puts_error).with('usage: :source path')
        expect(result).to eq false
      end
    end

    context 'with a file that fails to parse' do
      it 'prints an error message and returns false' do
        env = spy('env', puts_error: nil)
        command = described_class.new('source', ['/bad_script'])
        allow(Gitsh::FileRunner).
          to receive(:run).and_raise(Gitsh::ParseError, 'Oh no!')

        result = command.execute(env)

        expect(env).to have_received(:puts_error).with('gitsh: Oh no!')
        expect(result).to eq false
      end
    end
  end
end
