require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand::Chdir do
  it_behaves_like "an internal command"

  describe '#execute' do
    it 'returns true for correct directories' do
      env = double('Environment', puts_error: true)
      command = described_class.new('cd', ['./'])

      expect(command.execute(env)).to be_truthy
    end

    it 'returns true for no argument' do
      env = double('Environment', puts_error: true)
      allow(env).to receive(:fetch).with(:_root).and_return(Dir.pwd)
      command = described_class.new('cd', [])

      expect(command.execute(env)).to be_truthy
    end

    it 'returns false with invalid arguments' do
      env = double('Environment', puts_error: true)
      command = described_class.new('cd', ['foo'])

      expect(command.execute(env)).to be_falsey
    end
  end
end
