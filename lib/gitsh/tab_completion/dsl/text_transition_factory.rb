require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/matchers/text_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class TextTransitionFactory
        attr_reader :word

        def initialize(word)
          @word = word
        end

        def build(start_state, options = {})
          end_state = options.fetch(:end_state) { Automaton::State.new(word) }
          start_state.add_transition(Matchers::TextMatcher.new(word), end_state)
          end_state
        end
      end
    end
  end
end
