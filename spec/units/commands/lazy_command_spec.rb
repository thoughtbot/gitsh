require 'spec_helper'
require 'gitsh/commands/lazy_command'
require 'gitsh/arguments/string_argument'
require 'gitsh/arguments/variable_argument'

describe Gitsh::Commands::LazyCommand do
  describe '#execute' do
    it 'executes Git commands' do
      env = double(:env)
      command_instance = stub_command_class(Gitsh::Commands::GitCommand)
      lazy_command = Gitsh::Commands::LazyCommand.new([string('status')])

      lazy_command.execute(env)

      expect(command_instance).to have_received(:execute).with(env)
      expect(Gitsh::Commands::GitCommand).to have_received(:new).with(
        'status',
        [],
      )
    end

    it 'executes internal commands' do
      env = double(:env)
      command_instance = stub_command_class(
        Gitsh::Commands::InternalCommand,
        instance_class: Gitsh::Commands::InternalCommand::Echo,
      )
      lazy_command = Gitsh::Commands::LazyCommand.new([string(':echo')])

      lazy_command.execute(env)

      expect(command_instance).to have_received(:execute).with(env)
      expect(Gitsh::Commands::InternalCommand).to have_received(:new).with(
        'echo',
        [],
      )
    end

    it 'executes shell commands' do
      env = double(:env)
      command_instance = stub_command_class(Gitsh::Commands::ShellCommand)
      lazy_command = Gitsh::Commands::LazyCommand.new([string('!ls')])

      lazy_command.execute(env)

      expect(command_instance).to have_received(:execute).with(env)
      expect(Gitsh::Commands::ShellCommand).to have_received(:new).with(
        'ls',
        [],
      )
    end

    context 'the command raises an error' do
      it 'prints the error and returns false' do
        env = spy('env', puts_error: nil)
        command_instance = stub_command_class(Gitsh::Commands::GitCommand)
        allow(command_instance).to receive(:execute).
          and_raise(Gitsh::Error, 'Oh noes!')
        handler = Gitsh::Commands::LazyCommand.new([string('status')])

        expect(handler.execute(env)).to eq false
        expect(env).to have_received(:puts_error).with('gitsh: Oh noes!')
      end
    end

    context 'with arguments' do
      it 'calculates argument values before passing them on' do
        env = double(:env)
        allow(env).to receive(:fetch).with('foo').and_return('value')
        command_instance = stub_command_class(Gitsh::Commands::ShellCommand)
        lazy_command = Gitsh::Commands::LazyCommand.new([
          string('!ls'),
          var('foo'),
        ])

        lazy_command.execute(env)

        expect(command_instance).to have_received(:execute).with(env)
        expect(Gitsh::Commands::ShellCommand).to have_received(:new).with(
          'ls',
          ['value'],
        )
      end
    end
  end

  def stub_command_class(klass, instance_class: klass)
    command_instance = instance_double(instance_class, execute: true)
    allow(klass).to receive(:new).and_return(command_instance)
    command_instance
  end

  def string(value)
    Gitsh::Arguments::StringArgument.new(value)
  end

  def var(name)
    Gitsh::Arguments::VariableArgument.new(name)
  end
end
