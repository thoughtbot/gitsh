require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/matchers/unknown_option_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class OptionTransitionFactory
        def build(start_state, options = {})
          @start_state = start_state
          @options = options

          invoke
        end

        private

        attr_reader :start_state, :options

        def invoke
          add_transitions_for_known_options
          add_transitions_for_unknown_options
          end_state
        end

        def add_transitions_for_known_options
          known_options_factory.build(
            start_state,
            options.merge(end_state: end_state),
          )
        end

        def add_transitions_for_unknown_options
          start_state.add_transition(
            Matchers::UnknownOptionMatcher.new,
            end_state,
          )
        end

        def end_state
          @end_state ||= options.fetch(:end_state) do
            Automaton::State.new('option')
          end
        end

        def known_options_factory
          options.fetch(:known_options_factory)
        end
      end
    end
  end
end
