require 'spec_helper'
require 'gitsh/commands/factory'

describe Gitsh::Commands::Factory do
  describe '#build' do
    it 'returns an instance of the given command class' do
      env = stub('env')
      error_handler = stub('error_handler')
      Gitsh::Commands::ErrorHandler.stubs(:new).returns(error_handler)
      command_instance = stub('command_instance')
      command_class = stub('command_class', new: command_instance)
      context = { env: env, command: 'status' }
      factory = Gitsh::Commands::Factory.new(command_class, context)

      built_instance = factory.build

      expect(built_instance).to be error_handler
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
        env,
      )
      expect(command_class).to have_received(:new).with(
        env,
        'status',
        instance_of(Gitsh::ArgumentList),
      )
    end
  end
end
