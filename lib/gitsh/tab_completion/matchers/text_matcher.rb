require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TextMatcher < BaseMatcher
        def initialize(word)
          @word = word
        end

        def match?(match_word)
          word == match_word
        end

        def eql?(other)
          super(other) && other.word == word
        end

        def hash
          super + word.hash
        end

        protected

        attr_reader :word

        def all_completions
          [word]
        end
      end
    end
  end
end
