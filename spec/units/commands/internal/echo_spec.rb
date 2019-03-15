require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Echo do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'prints all arguments to the environment joined with a space' do
      env = double('env', puts: nil)
      command = described_class.new('echo', ['foo', 'bar'])

      expect(command.execute(env)).to be_truthy
      expect(env).to have_received(:puts).with('foo bar')
    end

    it 'prints a newline when no arguments are passed' do
      env = double('env', puts: nil)
      command = described_class.new('echo', [])

      expect(command.execute(env)).to be_truthy
      expect(env).to have_received(:puts).with('')
    end
  end
end
