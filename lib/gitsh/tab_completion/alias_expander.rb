require 'gitsh/error'
require 'gitsh/tab_completion/tokens_to_words'

module Gitsh
  module TabCompletion
    class AliasExpander
      def initialize(words, env)
        @words = words
        @env = env
      end

      def call
        if expandable?
          expanded_alias_words + words.drop(1)
        else
          words
        end
      end

      private

      attr_reader :words, :env

      def expandable?
        !expanded_alias.start_with?('!')
      rescue Gitsh::UnsetVariableError
        false
      end

      def expanded_alias_words
        TokensToWords.call(expanded_alias_tokens)
      end

      def expanded_alias_tokens
        Lexer.lex(expanded_alias)
      rescue RLTK::LexingError
        []
      end

      def expanded_alias
        @_expanded_alias ||= env.fetch("alias.#{words.first}")
      end
    end
  end
end
