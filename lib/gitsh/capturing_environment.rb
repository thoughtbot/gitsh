require 'delegate'

module Gitsh
  class CapturingEnvironment < SimpleDelegator
    def initialize(env)
      super
      @reader, @writer = IO.pipe
    end

    def output_stream
      writer
    end

    def captured_output
      writer.close
      reader.read
    end

    private

    attr_reader :reader, :writer
  end
end
