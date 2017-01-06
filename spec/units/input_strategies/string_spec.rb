require 'spec_helper'
require 'gitsh/input_strategies/string'

describe Gitsh::InputStrategies::String do
  describe '#setup' do
    it 'is implemented' do
      input_strategy = described_class.new(command: double)

      expect(input_strategy).to respond_to :setup
    end
  end

  describe '#teardown' do
    it 'is implemented' do
      input_strategy = described_class.new(command: double)

      expect(input_strategy).to respond_to :teardown
    end
  end

  describe '#read_command' do
    it 'returns the command and then nil' do
      command = double
      input_strategy = described_class.new(command: command)
      input_strategy.setup

      expect(input_strategy.read_command).to eq command
      expect(input_strategy.read_command).to be_nil
    end
  end
end
