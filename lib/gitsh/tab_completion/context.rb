require 'gitsh/lexer'
require 'gitsh/tab_completion/tokens_to_words'

module Gitsh
  module TabCompletion
    class Context
      COMMAND_SEPARATORS = [
        :AND, :OR, :SEMICOLON, :LEFT_PAREN, :SUBSHELL_START, :EOL,
      ].freeze
      NOT_MEANINGFUL = [:EOS, :INCOMPLETE].freeze

      def initialize(input)
        @input = input
      end

      def prior_words
        words[0...-1]
      end

      def completing_variable?
        if meaningful_tokens.any?
          [:VAR, :MISSING].include?(meaningful_tokens.last.type)
        else
          false
        end
      end

      private

      attr_reader :input

      def words
        TokensToWords.call(last_command_tokens)
      end

      def last_command_tokens
        tokens.reverse_each.
          take_while { |token| !COMMAND_SEPARATORS.include?(token.type) }.
          reverse
      end

      def meaningful_tokens
        @_meaningful_tokens ||= tokens.reject do |token|
          NOT_MEANINGFUL.include?(token.type)
        end
      end

      def tokens
        @_tokens ||= lex
      end

      def lex
        Lexer.lex(input)
      rescue RLTK::LexingError
        []
      end
    end
  end
end
