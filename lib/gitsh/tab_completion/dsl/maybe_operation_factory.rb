module Gitsh
  module TabCompletion
    module DSL
      class MaybeOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end

        def build(start_state, options = {})
          end_state = child.build(start_state, options)
          start_state.add_free_transition(end_state)
          end_state
        end
      end
    end
  end
end
