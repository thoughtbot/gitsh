require 'spec_helper'
require 'gitsh/pipeline_environment'

describe Gitsh::PipelineEnvironment do
  describe '.build_pair' do
    it 'returns environments for both ends of a pipeline' do
      default_input_stream = double(:default_input_stream)
      default_output_stream = double(:default_output_stream)
      env = double(
        :env,
        input_stream: default_input_stream,
        output_stream: default_output_stream,
      )
      pipe_writer = double(:pipe_writer)
      pipe_reader = double(:pipe_reader)
      allow(IO).to receive(:pipe).and_return([pipe_reader, pipe_writer])

      left, right = described_class.build_pair(env)

      expect(left.input_stream).to eq default_input_stream
      expect(left.output_stream).to eq pipe_writer
      expect(right.input_stream).to eq pipe_reader
      expect(right.output_stream).to eq default_output_stream
    end
  end

  describe '#input_stream' do
    context 'when constructed with a custom input stream' do
      it 'returns the custom input stream' do
        env = double(:env)
        input_stream = double(:input_stream)
        pipeline_env = described_class.new(env, input_stream: input_stream)

        expect(pipeline_env.input_stream).to eq input_stream
      end
    end

    context 'when constructed with no custom input stream' do
      it 'returns the default environment\'s input stream' do
        input_stream = double(:input_stream)
        env = double(:env, input_stream: input_stream)
        pipeline_env = described_class.new(env, output_stream: double)

        expect(pipeline_env.input_stream).to eq input_stream
      end
    end
  end

  describe '#output_stream' do
    context 'when constructed with a custom output stream' do
      it 'returns the custom output stream' do
        env = double(:env)
        output_stream = double(:output_stream)
        pipeline_env = described_class.new(env, output_stream: output_stream)

        expect(pipeline_env.output_stream).to eq output_stream
      end
    end

    context 'when constructed with no custom output stream' do
      it 'returns the default environment\'s output stream' do
        output_stream = double(:output_stream)
        env = double(:env, output_stream: output_stream)
        pipeline_env = described_class.new(env, input_stream: double)

        expect(pipeline_env.output_stream).to eq output_stream
      end
    end
  end

  describe 'delegations' do
    it 'delegates unknown methods to the wrapped environment' do
      return_value = double(:return_value)
      env = double(:env, foo: return_value)
      pipeline_env = described_class.new(env, input_stream: double)

      expect(pipeline_env).to respond_to(:foo)
      expect(pipeline_env.foo).to eq return_value
    end
  end
end
