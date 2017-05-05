module Gitsh
  module TabCompletion
    module DSL
      class ConcatenationFactory
        attr_reader :parts

        def initialize(parts)
          @parts = parts
        end

        def build(start_state, options = {})
          end_state = options.delete(:end_state)
          next_state = parts.inject(start_state) do |state, part|
            part.build(state, options)
          end

          if end_state
            next_state.add_free_transition(end_state)
            end_state
          else
            next_state
          end
        end
      end
    end
  end
end
