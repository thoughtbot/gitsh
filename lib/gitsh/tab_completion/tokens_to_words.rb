module Gitsh
  module TabCompletion
    class TokensToWords
      def self.call(tokens)
        new(tokens).call
      end

      def initialize(tokens)
        @tokens = tokens
      end

      def call
        words
      end

      private

      attr_reader :tokens

      def words
        token_groups.map do |tokens|
          tokens.inject('') do |result, token|
            case token.type
            when :WORD
              result + token.value
            when :VAR
              result + "${#{token.value}}"
            else
              result
            end
          end
        end
      end

      def token_groups
        tokens.
          chunk { |token| token.type == :SPACE }.
          inject([]) do |result, (is_space, token_group)|
            if is_space
              result
            else
              [*result, token_group]
            end
          end
      end
    end
  end
end
