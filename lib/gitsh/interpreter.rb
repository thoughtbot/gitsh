require 'rltk'
require 'gitsh/commands/noop'
require 'gitsh/error'
require 'gitsh/lexer'
require 'gitsh/parser'

module Gitsh
  class Interpreter
    def initialize(env:, input_strategy:)
      @env = env
      @input_strategy = input_strategy
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

    attr_reader :env, :input_strategy

    def execute(input)
      build_command(input).execute(env)
    rescue RLTK::LexingError, RLTK::NotInLanguage, RLTK::BadToken, EOFError
      input_strategy.handle_parse_error('parse error')
    end

    def build_command(input)
      tokens = Lexer.lex(input)

      if incomplete_command?(tokens)
        continuation = input_strategy.read_continuation
        build_multi_line_command(input, continuation)
      else
        Parser.parse(tokens)
      end
    end

    def incomplete_command?(tokens)
      tokens.reverse_each.detect { |token| token.type == :INCOMPLETE }
    end

    def build_multi_line_command(previous_lines, new_line)
      if new_line.nil?
        Commands::Noop.new
      else
        build_command([previous_lines, new_line].join("\n"))
      end
    end
  end
end
