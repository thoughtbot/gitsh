module Gitsh
  module TabCompletion
    module DSL
      class PlusOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end

        def build(start_state, options = {})
          end_state = child.build(start_state, options)
          end_state.add_free_transition(start_state)
          end_state
        end
      end
    end
  end
end
