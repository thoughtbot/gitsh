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

    def print(*args)
      output_stream.print(*args)
    end

    def puts(*args)
      output_stream.puts(*args)
    end

    def captured_output
      writer.close
      reader.read
    end

    private

    attr_reader :reader, :writer
  end
end
