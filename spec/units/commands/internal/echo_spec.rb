require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Echo do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'prints all arguments to the environment joined with a space' do
      env = stub('env', puts: nil)
      command = described_class.new(env, 'echo', arguments('foo', 'bar'))

      expect(command.execute).to be_truthy
      expect(env).to have_received(:puts).with('foo bar')
    end

    it 'prints a newline when no arguments are passed' do
      env = stub('env', puts: nil)
      command = described_class.new(env, 'echo', arguments())

      expect(command.execute).to be_truthy
      expect(env).to have_received(:puts).with('')
    end
  end
end
