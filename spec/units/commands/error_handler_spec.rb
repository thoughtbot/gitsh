require 'spec_helper'
require 'gitsh/commands/error_handler'

describe Gitsh::Commands::ErrorHandler do
  describe '#execute' do
    context 'the command executes successfully' do
      it 'returns the same value as the command' do
        env = double('env')
        successful_execution = double('successful_execution')
        command_instance = double('command_instance', execute: successful_execution)
        handler = Gitsh::Commands::ErrorHandler.new(command_instance, env)

        expect(handler.execute).to be command_instance.execute
      end
    end

    context 'the command raises an error' do
      it 'prints the error and returns false' do
        env = spy('env', puts_error: nil)
        command_instance = double('command_instance')
        allow(command_instance).to receive(:execute).
          and_raise(Gitsh::Error, 'Oh noes!')
        handler = Gitsh::Commands::ErrorHandler.new(command_instance, env)

        expect(handler.execute).to eq false
        expect(env).to have_received(:puts_error).with('gitsh: Oh noes!')
      end
    end
  end
end
