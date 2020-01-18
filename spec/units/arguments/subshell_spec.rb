require 'spec_helper'
require 'gitsh/arguments/subshell'

describe Gitsh::Arguments::Subshell do
  describe '#value' do
    it 'returns the result of executing the subshell' do
      capturing_environment = stub_capturing_environment('expected output')
      env = double('env')
      wrapped_command = double(:command, execute: nil)
      subshell = described_class.new(wrapped_command)

      output = subshell.value(env)

      expect(output).to eq ['expected output']
      expect(wrapped_command).to have_received(:execute).with(capturing_environment)
    end
  end

  describe '#==' do
    it 'returns true when the commands are equal' do
      a1 = described_class.new('A')
      a2 = described_class.new('A')

      expect(a1).to eq a2
    end

    it 'returns false when the commands are not equal' do
      a = described_class.new('A')
      b = described_class.new('B')

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new('A')
      double_a = double(command: 'A')

      expect(arg_a).not_to eq double_a
    end
  end

  def stub_capturing_environment(output)
    env = double(:capturing_environment, captured_output: output)
    allow(Gitsh::CapturingEnvironment).to receive(:new).and_return(env)
    env
  end
end
