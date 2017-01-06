require 'gitsh/error'
require 'gitsh/parser'

module Gitsh
  class Interpreter
    def initialize(options)
      @env = options.fetch(:env)
      @parser_factory = options.fetch(:parser_factory, Parser)
      @input_strategy = options.fetch(:input_strategy)
    end

    def run
      input_strategy.setup
      while command = input_strategy.read_command
        execute(command)
      end
    ensure
      input_strategy.teardown
    end

    private

    attr_reader :env, :parser_factory, :input_strategy

    def execute(input)
      build_command(input).execute
    rescue Parslet::ParseFailed
      env.puts_error('gitsh: parse error')
    end

    def build_command(input)
      parser.parse_and_transform(input)
    end

    def parser
      @parser ||= parser_factory.new(env: env)
    end
  end
end
