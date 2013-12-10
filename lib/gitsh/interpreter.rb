require 'gitsh/parser'

module Gitsh
  class Interpreter
    def initialize(env, options={})
      @env = env
      @parser_factory = options.fetch(:parser_factory, Parser)
    end

    def execute(input)
      build_command(input).execute
    rescue Parslet::ParseFailed
      env.puts_error('gitsh: parse error')
    end

    private

    attr_reader :env, :parser_factory

    def build_command(input)
      parser.parse_and_transform(input, env)
    end

    def parser
      @parser ||= parser_factory.new
    end
  end
end
