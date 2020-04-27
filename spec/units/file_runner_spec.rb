require 'spec_helper'
require 'gitsh/file_runner'

describe Gitsh::FileRunner do
  describe '#run' do
    it 'executes the given script' do
      input_strategy = stub_file_input_strategy
      interpreter = stub_interpreter
      env = double(:env)
      runner = described_class.new(env: env, path: 'my/path')

      runner.run

      expect(interpreter).to have_received(:run)
      expect(Gitsh::Interpreter).to have_received(:new).with(
        env: env,
        input_strategy: input_strategy,
      )
      expect(Gitsh::InputStrategies::File).to have_received(:new).with(
        path: 'my/path',
      )
    end
  end

  def stub_file_input_strategy
    input_strategy = double(:input_strategy)
    allow(Gitsh::InputStrategies::File).to receive(:new).
      and_return(input_strategy)
    input_strategy
  end

  def stub_interpreter
    interpreter = double(:interpreter, run: nil)
    allow(Gitsh::Interpreter).to receive(:new).and_return(interpreter)
    interpreter
  end
end
