require 'gitsh/interpreter'
require 'gitsh/input_strategies/file'

module Gitsh
  class FileRunner
    def self.run(opts)
      new(opts).run
    end

    def initialize(opts)
      @env = opts.fetch(:env)
      @path = opts.fetch(:path)
    end

    def run
      interpreter.run
    end

    private

    attr_reader :env, :path

    def interpreter
      Interpreter.new(env: env, input_strategy: input_strategy)
    end

    def input_strategy
      InputStrategies::File.new(env: env, path: path)
    end
  end
end
