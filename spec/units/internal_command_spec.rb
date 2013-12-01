require 'spec_helper'
require 'gitsh/internal_command'

describe Gitsh::InternalCommand do
  describe '.new' do
    it 'returns a Set command when given the command "set"' do
      env = stub
      command = described_class.new(env, 'set', %w(foo bar))
      expect(command).to be_a Gitsh::InternalCommand::Set
    end
  end

  describe Gitsh::InternalCommand::Set do
    describe '#execute' do
      it 'sets a variable on the environment' do
        env = stub(:[]=)
        command = Gitsh::InternalCommand::Set.new(env, %w(foo bar))

        command.execute

        expect(env).to have_received(:[]=).with('foo', 'bar')
      end
    end
  end
end
