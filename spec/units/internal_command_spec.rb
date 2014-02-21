require 'spec_helper'
require 'gitsh/internal_command'

describe Gitsh::InternalCommand do
  describe '.new' do
    it 'returns a Set command when given the command "set"' do
      command = described_class.new(stub('env'), 'set', %w(foo bar))
      expect(command).to be_a Gitsh::InternalCommand::Set
    end

    it 'returns an Exit command when given the command "exit"' do
      command = described_class.new(stub('env'), 'exit')
      expect(command).to be_a Gitsh::InternalCommand::Exit
    end

    it 'returns a Chdir command when given the command "cd"' do
      command = described_class.new(stub('env'), 'cd', '/some/path')
      expect(command).to be_a Gitsh::InternalCommand::Chdir
    end

    it 'returns an Unknown command when given anything else' do
      command = described_class.new(stub('env'), 'notacommand', %w(foo bar))
      expect(command).to be_a Gitsh::InternalCommand::Unknown
    end
  end

  describe '.commands' do
    it 'returns a list of recognised commands' do
      expect(described_class.commands).to eq %w( :set :cd :exit )
    end
  end

  describe Gitsh::InternalCommand::Chdir do
    describe '#execute' do
      it 'returns true for correct directories' do
        env = stub(:[]= => true, puts_error: true)
        command = Gitsh::InternalCommand::Chdir.new(env, 'cd', ['./'])

        expect(command.execute).to be_true
      end

      it 'returns false with invalid arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = Gitsh::InternalCommand::Chdir.new(env, 'cd', ['foo'])

        expect(command.execute).to be_false
      end
    end
  end

  describe Gitsh::InternalCommand::Set do
    describe '#execute' do
      it 'sets a variable on the environment' do
        env = stub('env', :[]=)
        command = Gitsh::InternalCommand::Set.new(env, 'set', %w(foo bar))

        command.execute

        expect(env).to have_received(:[]=).with('foo', 'bar')
      end

      it 'returns true with correct arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = Gitsh::InternalCommand::Set.new(env, 'set', %w(foo bar))

        expect(command.execute).to be_true
      end

      it 'returns false with invalid arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = Gitsh::InternalCommand::Set.new(env, 'set', %w(foo))

        expect(command.execute).to be_false
      end
    end
  end

  describe Gitsh::InternalCommand::Exit do
    describe '#execute' do
      it 'exits the program' do
        command = Gitsh::InternalCommand::Exit.new(stub('env'), 'exit')
        expect { command.execute }.to raise_exception(SystemExit)
      end
    end
  end

  describe Gitsh::InternalCommand::Unknown do
    describe '#execute' do
      it 'outputs an error message' do
        env = stub('env', puts_error: nil)
        command = Gitsh::InternalCommand::Unknown.new(env, 'notacommand')

        command.execute

        expect(env).to have_received(:puts_error).with(
          'gitsh: notacommand: command not found'
        )
      end
    end
  end
end
