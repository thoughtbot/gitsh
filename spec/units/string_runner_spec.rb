require 'spec_helper'
require 'gitsh/string_runner'

describe Gitsh::StringRunner do
  describe '#run' do
    it 'executes the given command' do
      input_strategy = stub_string_input_strategy
      interpreter = stub_interpreter
      env = double(:env)
      runner = described_class.new(env: env, command: 'status')

      runner.run

      expect(interpreter).to have_received(:run)
      expect(Gitsh::Interpreter).to have_received(:new).with(
        env: env,
        input_strategy: input_strategy,
      )
      expect(Gitsh::InputStrategies::String).to have_received(:new).with(
        command: 'status',
      )
    end
  end

  def stub_string_input_strategy
    input_strategy = double(:input_strategy)
    allow(Gitsh::InputStrategies::String).to receive(:new).
      and_return(input_strategy)
    input_strategy
  end

  def stub_interpreter
    interpreter = double(:interpreter, run: nil)
    allow(Gitsh::Interpreter).to receive(:new).and_return(interpreter)
    interpreter
  end
end
