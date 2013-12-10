module Gitsh
  class Environment
    DEFAULT_GIT_COMMAND = '/usr/bin/env git'.freeze

    attr_reader :output_stream, :error_stream
    attr_accessor :git_command

    def initialize(options={})
      @output_stream = options.fetch(:output_stream, $stdout)
      @error_stream = options.fetch(:error_stream, $stderr)
      @git_command = DEFAULT_GIT_COMMAND
      @variables = Hash.new
    end

    def [](key)
      variables[key.to_sym]
    end

    def []=(key, value)
      variables[key.to_sym] = value
    end

    def print(*args)
      output_stream.print(*args)
    end

    def puts(*args)
      output_stream.puts(*args)
    end

    def puts_error(*args)
      error_stream.puts(*args)
    end

    private

    attr_reader :variables
  end
end
