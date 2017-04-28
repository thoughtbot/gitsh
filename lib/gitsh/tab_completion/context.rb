require 'gitsh/lexer'

module Gitsh
  module TabCompletion
    class Context
      COMMAND_SEPARATORS = [
        :AND, :OR, :SEMICOLON, :LEFT_PAREN, :SUBSHELL_START, :EOL,
      ].freeze

      def initialize(input)
        @input = input
      end

      def prior_words
        words[0...-1]
      end

      private

      attr_reader :input

      def words
        combine_words(split_by_spaces(last_command(tokens)))
      end

      def combine_words(token_groups)
        token_groups.map do |tokens|
          tokens.inject("") do |result, token|
            if token.type == :WORD
              result + token.value
            else
              result
            end
          end
        end
      end

      def split_by_spaces(command_tokens)
        command_tokens.
          chunk { |token| token.type == :SPACE }.
          inject([]) do |result, (is_space, token_group)|
            if is_space
              result
            else
              result + [token_group]
            end
          end
      end

      def last_command(tokens)
        tokens.reverse_each.
          take_while { |token| !COMMAND_SEPARATORS.include?(token.type) }.
          reverse
      end

      def tokens
        Lexer.lex(input)
      rescue RLTK::LexingError
        []
      end
    end
  end
end
