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
          root.build(start_state, context: self)
        end

        def options_with_arguments
          options.select(&:has_argument?)
        end

        def options_without_arguments
          options.reject(&:has_argument?)
        end
      end
    end
  end
end
