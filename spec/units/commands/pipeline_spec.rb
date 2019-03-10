require 'spec_helper'
require 'gitsh/commands/pipeline'
require 'gitsh/commands/git_command'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::Pipeline do
  describe '#execute' do
    it 'pipes output of left command to right command' do
      left_command = create_command_double { 'string' }
      right_command = create_command_double { |input| input.upcase }
      env = build_env
      pipeline = described_class.new(left_command, right_command)

      result = pipeline.execute(env)

      expect(result).to be true
      expect(env.output_stream.string).to eq "STRING\n"
    end

    context 'when the left command fails' do
      it 'returns false' do
        left_command = create_command_double(false) { '' }
        right_command = create_command_double { |input| input.upcase }
        pipeline = described_class.new(left_command, right_command)

        result = pipeline.execute(build_env)

        expect(result).to be false
      end
    end

    context 'when the right command fails' do
      it 'returns false' do
        left_command = create_command_double { 'string' }
        right_command = create_command_double(false) { '' }
        pipeline = described_class.new(left_command, right_command)

        result = pipeline.execute(build_env)

        expect(result).to be false
      end
    end
  end

  def create_command_double(value=true)
    command = instance_double(Gitsh::Commands::GitCommand)
    allow(command).to receive(:execute) do |env|
      input = env.input_stream.read
      env.output_stream.puts yield(input)
      value
    end
    command
  end

  def build_env
    Gitsh::Environment.new(
      input_stream: instance_double(IO, read: ""),
      output_stream: StringIO.new
    )
  end
end
