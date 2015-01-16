require 'gitsh/error'
require 'gitsh/interpreter'

module Gitsh
  class ScriptRunner
    STDIN_PLACEHOLDER = '-'.freeze

    def initialize(opts)
      @env = opts[:env]
      @interpreter = opts.fetch(:interpreter) { Interpreter.new(@env) }
    end

    def run(path)
      open_file(path) do |f|
        f.each_line { |line| interpreter.execute(line) }
      end
    rescue Errno::ENOENT
      raise NoInputError, "#{path}: No such file or directory"
    rescue Errno::EACCES
      raise NoInputError, "#{path}: Permission denied"
    end

    private

    attr_reader :interpreter, :env

    def open_file(path, &block)
      if path == STDIN_PLACEHOLDER
        block.call(env.input_stream)
      else
        File.open(path, &block)
      end
    end
  end
end
