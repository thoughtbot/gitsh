require 'gitsh/tab_completion/matchers/option_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class VariableTransitionFactory
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def build(start_state, options = {})
          end_state = options.fetch(:end_state) { Automaton::State.new(name) }
          start_state.add_transition(matcher(options), end_state)
          end_state
        end

        private

        def matcher(options)
          #FIXME: Other matcher classes
          #FIXME: Configure OptionMatcher with options[:context].options etc.
          #FIXME: Extra transitions for options with arguments
          #FIXME: Configure other matcher classes with an Environment
          Matchers::OptionMatcher.new
        end
      end
    end
  end
end
