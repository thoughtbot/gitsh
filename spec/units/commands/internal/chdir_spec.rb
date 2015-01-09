require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Chdir do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'returns true for correct directories' do
      env = stub(:[]= => true, puts_error: true)
      command = described_class.new(env, 'cd', arguments('./'))

      expect(command.execute).to be_true
    end

    it 'returns false with invalid arguments' do
      env = stub(:[]= => true, puts_error: true)
      command = described_class.new(env, 'cd', arguments('foo'))

      expect(command.execute).to be_false
    end
  end
end
