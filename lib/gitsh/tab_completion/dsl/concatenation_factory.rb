module Gitsh
  module TabCompletion
    module DSL
      class ConcatenationFactory
        attr_reader :parts

        def initialize(parts)
          @parts = parts
        end

        def build(start_state, options = {})
          with_optional_end_state(options) do
            parts.inject(start_state) do |state, part|
              part.build(state, options)
            end
          end
        end

        private

        def with_optional_end_state(options)
          end_state = options.delete(:end_state)

          if end_state
            last_state = yield
            last_state.add_free_transition(end_state)
            end_state
          else
            yield
          end
        end
      end
    end
  end
end
