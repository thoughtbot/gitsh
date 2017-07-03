module Gitsh
  module TabCompletion
    module DSL
      class RuleFactory
        attr_reader :root, :options

        def initialize(root, options)
          @root = root
          @options = options
        end

        def build(start_state)
          root.build(start_state, known_options_factory: options)
        end
      end
    end
  end
end
