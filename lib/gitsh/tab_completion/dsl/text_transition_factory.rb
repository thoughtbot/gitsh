require 'gitsh/tab_completion/automaton'

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
          start_state.add_text_transition(word, end_state)
          end_state
        end
      end
    end
  end
end
