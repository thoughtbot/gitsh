require 'rltk'
require 'gitsh/error'
require 'gitsh/lexer'
require 'gitsh/parser'

module Gitsh
  class Interpreter
    def initialize(options)
      @env = options.fetch(:env)
      @lexer = options.fetch(:lexer, Lexer)
      @parser = options.fetch(:parser, Parser)
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

    attr_reader :env, :parser, :lexer, :input_strategy

    def execute(input)
      build_command(input).execute(env)
    rescue RLTK::LexingError, RLTK::NotInLanguage, RLTK::BadToken
      env.puts_error('gitsh: parse error')
    end

    def build_command(input)
      parser.parse(lexer.lex(input))
    end
  end
end
