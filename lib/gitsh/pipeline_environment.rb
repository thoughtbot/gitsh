require 'delegate'

module Gitsh
  class PipelineEnvironment < SimpleDelegator
    def self.build_pair(env)
      pipe_reader, pipe_writer = IO.pipe
      [
        new(env, output_stream: pipe_writer),
        new(env, input_stream: pipe_reader),
      ]
    end

    def initialize(env, options)
      super(env)
      @input_stream = options[:input_stream]
      @output_stream = options[:output_stream]
    end

    def input_stream
      @input_stream || super
    end

    def output_stream
      @output_stream || super
    end
  end
end
