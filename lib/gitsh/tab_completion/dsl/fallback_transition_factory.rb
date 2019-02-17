require 'gitsh/tab_completion/automaton'

module Gitsh
  module TabCompletion
    module DSL
      class FallbackTransitionFactory
        attr_reader :matcher

        def initialize(matcher)
          @matcher = matcher
        end

        def build(start_state, options = {})
          end_state = options.fetch(:end_state) do
            Automaton::State.new('fallback')
          end
          start_state.add_fallback_transition(matcher, end_state)
          end_state
        end
      end
    end
  end
end
