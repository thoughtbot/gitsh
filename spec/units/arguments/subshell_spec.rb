require 'spec_helper'
require 'gitsh/arguments/subshell'

describe Gitsh::Arguments::Subshell do
  class FakeInterpreter
    def initialize(env)
      @env = env
    end

    def execute(command)
      @env.output_stream.puts "Begin.\n#{command}.\nEnd."
      true
    end
  end

  describe '#value' do
    it 'creates a new interpreter and executes the subshell command inside of it' do
      env = double('env')
      subshell_command = 'status'

      output = described_class.new(
        subshell_command,
        interpreter_factory: FakeInterpreter,
      ).value(env)

      expect(output).to eq %Q{Begin. #{subshell_command}. End.}
    end
  end
end
