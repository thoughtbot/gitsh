require 'set'

module Gitsh
  module TabCompletion
    class Automaton
      def initialize(start_state)
        @start_state = start_state
      end

      def match(tokens)
        tokens.inject(start_states) do |current_states, token|
          current_states.map { |state| state.follow(token) }.inject(Set.new, :|)
        end
      end

      def completions(context, token)
        match(context).flat_map { |state| state.completions(token) }
      end

      private

      attr_reader :start_state

      def start_states
        start_state.freely_reachable
      end

      class State
        attr_reader :free_transitions

        def initialize(name)
          @name = name
          @transitions = Hash.new { |h, k| h[k] = Set.new }
          @free_transitions = Set.new
        end

        def add_transition(matcher, state)
          transitions[matcher] << state
        end

        def add_free_transition(state)
          free_transitions << state
        end

        def follow(token)
          matching_transitions(token).map(&:freely_reachable).inject(Set.new, :|)
        end

        def freely_reachable
          free_transitions.map(&:freely_reachable).inject([self].to_set, :|)
        end

        def completions(token)
          transitions.keys.flat_map { |matcher| matcher.completions(token) }
        end

        def inspect
          "<State:#{name}>"
        end

        private

        attr_reader :transitions, :name

        def matching_transitions(token)
          transitions.inject(Set.new) do |matched_states, (matcher, states)|
            if matcher.match?(token)
              matched_states | states
            else
              matched_states
            end
          end
        end
      end
    end
  end
end
