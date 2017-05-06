require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TextMatcher < BaseMatcher
        attr_reader :word

        def initialize(word)
          @word = word
        end

        def name
          'text'
        end

        def match?(match_word)
          word == match_word
        end

        def completions(token)
          if word.start_with?('-') ^ token.start_with?('-')
            []
          else
            super
          end
        end

        def eql?(other)
          super(other) && other.word == word
        end

        def hash
          super + word.hash
        end

        private

        def all_completions
          [word]
        end
      end
    end
  end
end
