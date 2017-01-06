require 'spec_helper'
require 'gitsh/arguments/subshell'

describe Gitsh::Arguments::Subshell do
  describe '#value' do
    it 'returns the result of executing the subshell' do
      capturing_environment = stub_capturing_environment('expected output')
      allow(Gitsh::StringRunner).to receive(:run)
      env = double('env')
      subshell = described_class.new('status')

      output = subshell.value(env)

      expect(output).to eq 'expected output'
      expect(Gitsh::StringRunner).to have_received(:run).with(
        env: capturing_environment,
        command: 'status',
      )
    end
  end

  def stub_capturing_environment(output)
    env = double(:capturing_environment, captured_output: output)
    allow(Gitsh::CapturingEnvironment).to receive(:new).and_return(env)
    env
  end
end
