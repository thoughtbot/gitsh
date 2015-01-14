require 'spec_helper'
require 'gitsh/commands/error_handler'

describe Gitsh::Commands::ErrorHandler do
  describe '#execute' do
    context 'the command executes successfully' do
      it 'returns the same value as the command' do
        env = stub('env')
        successful_execution = stub('successful_execution')
        command_instance = stub('command_instance', execute: successful_execution)
        handler = Gitsh::Commands::ErrorHandler.new(command_instance, env)

        expect(handler.execute).to be command_instance.execute
      end
    end

    context 'the command raises an error' do
      it 'prints the error and returns false' do
        env = stub('env', puts_error: nil)
        command_instance = stub('command_instance')
        command_instance.stubs(:execute).raises(Gitsh::Error, 'Oh noes!')
        handler = Gitsh::Commands::ErrorHandler.new(command_instance, env)

        expect(handler.execute).to eq false
        expect(env).to have_received(:puts_error).with('gitsh: Oh noes!')
      end
    end
  end
end
