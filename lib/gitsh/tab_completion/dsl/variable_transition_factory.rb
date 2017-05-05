module Gitsh
  module TabCompletion
    module DSL
      class VariableTransitionFactory
        attr_reader :matcher

        def initialize(matcher)
          @matcher = matcher
        end

        def build(start_state, options = {})
          end_state = options.fetch(:end_state) { Automaton::State.new('var') }
          start_state.add_transition(matcher, end_state)
          end_state
        end
      end
    end
  end
end
