require 'spec_helper'
require 'gitsh/commands/lazy_command'

describe Gitsh::Commands::LazyCommand do
  describe '#execute' do
    it 'executes Git commands' do
      env = double(:env)
      error_handler = stub_error_handler
      command_instance = stub_command_class(Gitsh::Commands::GitCommand)
      lazy_command = Gitsh::Commands::LazyCommand.new(command: 'status')

      lazy_command.execute(env)

      expect(error_handler).to have_received(:execute).with(env)
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(Gitsh::Commands::GitCommand).to have_received(:new).with(
        'status',
        instance_of(Gitsh::ArgumentList),
      )
    end

    it 'executes internal commands' do
      env = double(:env)
      error_handler = stub_error_handler
      command_instance = stub_command_class(
        Gitsh::Commands::InternalCommand,
        instance_class: Gitsh::Commands::InternalCommand::Echo,
      )
      lazy_command = Gitsh::Commands::LazyCommand.new(command: ':echo')

      lazy_command.execute(env)

      expect(error_handler).to have_received(:execute).with(env)
      expect(Gitsh::Commands::ErrorHandler).to have_received(:new).with(
        command_instance,
      )
      expect(Gitsh::Commands::InternalCommand).to have_received(:new).with(
        'echo',
        instance_of(Gitsh::ArgumentList),
      )
    end

    it 'executes shell commands' do
      env = double(:env)
      error_handler = stub_error_handler
      command_instance = stub_command_class(Gitsh::Commands::ShellCommand)
      lazy_command = Gitsh::Commands::LazyCommand.new(command: '!ls')

      lazy_command.execute(env)

      expect(error_handler).to have_received(:execute).with(env)
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
    stub_command_class(Gitsh::Commands::ErrorHandler)
  end

  def stub_command_class(klass, instance_class: klass)
    command_instance = instance_double(instance_class, execute: true)
    allow(klass).to receive(:new).and_return(command_instance)
    command_instance
  end
end
