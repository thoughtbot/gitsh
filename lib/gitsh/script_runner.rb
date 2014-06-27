require 'gitsh/exit_statuses'
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
      env.puts_error "gitsh: #{path}: No such file or directory"
      exit EX_NOINPUT
    rescue Errno::EACCES
      env.puts_error "gitsh: #{path}: Permission denied"
      exit EX_NOINPUT
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
