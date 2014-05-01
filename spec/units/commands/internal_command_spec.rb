require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand do
  describe '.new' do
    it 'returns a Set command when given the command "set"' do
      command = described_class.new(stub('env'), 'set', %w(foo bar))
      expect(command).to be_a described_class::Set
    end

    it 'returns an Exit command when given the command "exit"' do
      command = described_class.new(stub('env'), 'exit')
      expect(command).to be_a described_class::Exit
    end

    it 'returns an Exit command when given the command "q"' do
      command = described_class.new(stub('env'), 'q')
      expect(command).to be_a described_class::Exit
    end

    it 'returns a Chdir command when given the command "cd"' do
      command = described_class.new(stub('env'), 'cd', '/some/path')
      expect(command).to be_a described_class::Chdir
    end

    it 'returns an Unknown command when given anything else' do
      command = described_class.new(stub('env'), 'notacommand', %w(foo bar))
      expect(command).to be_a described_class::Unknown
    end
  end

  describe '.commands' do
    it 'returns a list of recognised commands' do
      expect(described_class.commands).to eq %w( :set :cd :exit :q :echo )
    end
  end

  describe described_class::Chdir do
    describe '#execute' do
      it 'returns true for correct directories' do
        env = stub(:[]= => true, puts_error: true)
        command = described_class::Chdir.new(env, 'cd', ['./'])

        expect(command.execute).to be_true
      end

      it 'returns false with invalid arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = described_class::Chdir.new(env, 'cd', ['foo'])

        expect(command.execute).to be_false
      end
    end
  end

  describe described_class::Set do
    describe '#execute' do
      it 'sets a variable on the environment' do
        env = stub('env', :[]=)
        command = described_class::Set.new(env, 'set', %w(foo bar))

        command.execute

        expect(env).to have_received(:[]=).with('foo', 'bar')
      end

      it 'returns true with correct arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = described_class::Set.new(env, 'set', %w(foo bar))

        expect(command.execute).to be_true
      end

      it 'returns false with invalid arguments' do
        env = stub(:[]= => true, puts_error: true)
        command = described_class::Set.new(env, 'set', %w(foo))

        expect(command.execute).to be_false
      end
    end
  end

  describe described_class::Echo do
    describe '#execute' do
      it 'prints all arguments to the environment joined with a space' do
        env = stub('env', puts: nil)
        command = described_class::Echo.new(env, 'echo', %w(foo bar))

        expect(command.execute).to be_true
        expect(env).to have_received(:puts).with('foo bar')
      end

      it 'prints a newline when no arguments are passed' do
        env = stub('env', puts: nil)
        command = described_class::Echo.new(env, 'echo', [])

        expect(command.execute).to be_true
        expect(env).to have_received(:puts).with('')
      end
    end
  end

  describe described_class::Exit do
    describe '#execute' do
      it 'exits the program' do
        command = described_class::Exit.new(stub('env'), 'exit')
        expect { command.execute }.to raise_exception(SystemExit)
      end
    end
  end

  describe described_class::Unknown do
    describe '#execute' do
      it 'outputs an error message' do
        env = stub('env', puts_error: nil)
        command = described_class::Unknown.new(env, 'notacommand')

        command.execute

        expect(env).to have_received(:puts_error).with(
          'gitsh: notacommand: command not found'
        )
      end
    end
  end
end
