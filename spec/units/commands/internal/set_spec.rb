require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Set do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'sets a variable on the environment' do
      env = spy('env')
      command = described_class.new('set', ['foo', 'bar'])

      command.execute(env)

      expect(env).to have_received(:[]=).with('foo', 'bar')
    end

    it 'returns true with correct arguments' do
      env = double('Environment', :[]= => true, puts_error: true)
      command = described_class.new('set', ['foo', 'bar'])

      expect(command.execute(env)).to be_truthy
    end

    it 'returns false with invalid arguments' do
      env = double('Environment', :[]= => true, puts_error: true)
      command = described_class.new('set', ['foo'])

      expect(command.execute(env)).to be_falsey
    end
  end
end
