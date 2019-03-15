require 'spec_helper'
require 'gitsh/commands/factory'

describe Gitsh::Commands::Factory do
  describe '#build' do
    it 'builds Git commands' do
      error_handler = stub_error_handler
      command_instance = stub_command_class(Gitsh::Commands::GitCommand)
      factory = Gitsh::Commands::Factory.new(command: 'status')

      built_instance = factory.build

      expect(built_instance).to be error_handler
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(Gitsh::Commands::GitCommand).to have_received(:new).with(
        'status',
        instance_of(Gitsh::ArgumentList),
      )
    end

    it 'builds internal commands' do
      error_handler = stub_error_handler
      command_instance = stub_command_class(Gitsh::Commands::InternalCommand)
      factory = Gitsh::Commands::Factory.new(command: ':echo')

      built_instance = factory.build

      expect(built_instance).to be error_handler
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(Gitsh::Commands::InternalCommand).to have_received(:new).with(
        'echo',
        instance_of(Gitsh::ArgumentList),
      )
    end

    it 'builds shell commands' do
      error_handler = stub_error_handler
      command_instance = stub_command_class(Gitsh::Commands::ShellCommand)
      factory = Gitsh::Commands::Factory.new(command: '!ls')

      built_instance = factory.build

      expect(built_instance).to be error_handler
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(Gitsh::Commands::ShellCommand).to have_received(:new).with(
        'ls',
        instance_of(Gitsh::ArgumentList),
      )
    end
  end

  def stub_error_handler
    error_handler = double('error_handler')
    allow(Gitsh::Commands::ErrorHandler).to receive(:new).
      and_return(error_handler)
    error_handler
  end

  def stub_command_class(klass)
    command_instance = instance_double(klass)
    allow(klass).to receive(:new).and_return(command_instance)
    command_instance
  end
end
