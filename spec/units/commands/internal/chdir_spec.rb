require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Chdir do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'returns true for correct directories' do
      env = double('Environment', :[]= => true, puts_error: true)
      command = described_class.new('cd', arguments('./'))

      expect(command.execute(env)).to be_truthy
    end

    it 'returns false with invalid arguments' do
      env = double('Environment', :[]= => true, puts_error: true)
      command = described_class.new('cd', arguments('foo'))

      expect(command.execute(env)).to be_falsey
    end
  end
end
