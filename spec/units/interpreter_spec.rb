require 'spec_helper'
require 'gitsh/interpreter'

describe Gitsh::Interpreter do
  describe '#execute' do
    it 'passes the command to a git command' do
      env = stub('env')
      git_command = stub('driver', execute: nil)
      git_command_factory = stub(new: git_command)

      interpreter = described_class.new(
        env,
        git_command_factory: git_command_factory
      )
      interpreter.execute('add -p')

      expect(git_command_factory).to have_received(:new).with('add -p')
      expect(git_command).to have_received(:execute).with(env)
    end
  end
end
