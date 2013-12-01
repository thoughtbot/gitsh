require 'spec_helper'
require 'gitsh/internal_command'

describe Gitsh::InternalCommand do
  describe '.new' do
    it 'returns a Set command when given the command "set"' do
      command = described_class.new(stub('env'), 'set', %w(foo bar))
      expect(command).to be_a Gitsh::InternalCommand::Set
    end

    it 'returns an Unknown command when given anything else' do
      command = described_class.new(stub('env'), 'notacommand', %w(foo bar))
      expect(command).to be_a Gitsh::InternalCommand::Unknown
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
