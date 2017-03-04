require 'spec_helper'
require 'gitsh/commands/factory'

describe Gitsh::Commands::Factory do
  describe '#build' do
    it 'returns an instance of the given command class' do
      error_handler = double('error_handler')
      allow(Gitsh::Commands::ErrorHandler).to receive(:new).
        and_return(error_handler)
      command_instance = double('command_instance')
      command_class = spy('command_class', new: command_instance)
      context = { command: 'status' }
      factory = Gitsh::Commands::Factory.new(command_class, context)

      built_instance = factory.build

      expect(built_instance).to be error_handler
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(command_class).to have_received(:new).with(
        'status',
        instance_of(Gitsh::ArgumentList),
      )
    end
  end
end
