module Gitsh
  module TabCompletion
    module DSL
      class StarOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end

        def build(start_state, options = {})
          child.build(start_state, options.merge(end_state: start_state))
        end
      end
    end
  end
end
