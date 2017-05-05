require 'gitsh/tab_completion/matchers/option_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class OptionTransitionFactory
        def build(start_state, options = {})
          end_state = options.fetch(:end_state) { Automaton::State.new('opt') }
          context = options.fetch(:context)
          Instance.new(start_state, end_state, context).build
          end_state
        end

        private

        class Instance
          def initialize(start_state, end_state, context)
            @start_state = start_state
            @end_state = end_state
            @context = context
          end

          def build
            build_transitions_for_options_without_arguments
            build_transitions_for_options_with_arguments
          end

          private

          attr_reader :start_state, :end_state, :context

          def build_transitions_for_options_without_arguments
            options = context.options_without_arguments.map(&:name)
            exclude_options = context.options_with_arguments.map(&:name)
            start_state.add_transition(
              Matchers::OptionMatcher.new(options, exclude_options),
              end_state,
            )
          end

          def build_transitions_for_options_with_arguments
            context.options_with_arguments.each do |option|
              intermediate_state = Automaton::State.new(option.name)
              start_state.add_text_transition(option.name, intermediate_state)
              option.argument_factory.build(
                intermediate_state,
                end_state: end_state,
              )
            end
          end
        end
      end
    end
  end
end
