require 'gitsh/input_strategies/string'

module Gitsh
  class StringRunner
    def self.run(opts)
      new(opts).run
    end

    def initialize(opts)
      @env = opts.fetch(:env)
      @command = opts.fetch(:command)
    end

    def run
      interpreter.run
    end

    private

    attr_reader :env, :command

    def interpreter
      Interpreter.new(env: env, input_strategy: input_strategy)
    end

    def input_strategy
      InputStrategies::String.new(command: command)
    end
  end
end
