module Gitsh
  module TabCompletion
    module DSL
      class RuleFactory
        attr_reader :root

        def initialize(root)
          @root = root
        end

        def build(start_state)
          root.build(start_state)
        end
      end
    end
  end
end
