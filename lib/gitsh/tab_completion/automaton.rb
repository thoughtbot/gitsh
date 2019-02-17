require 'set'

module Gitsh
  module TabCompletion
    class Automaton
      def initialize(start_state)
        @start_state = start_state
      end

      def completions(context, token)
        match(context).flat_map { |state| state.completions(token) }.uniq
      end

      def match(tokens)
        tokens.inject(start_states) do |current_states, token|
          current_states.map { |state| state.follow(token) }.inject(Set.new, :|)
        end
      end

      def accept_visitor(visitor)
        start_state.accept_visitor(visitor, Set.new)
      end

      private

      attr_reader :start_state

      def start_states
        start_state.freely_reachable
      end

      class State
        attr_reader :name

        def initialize(name)
          @name = name
          @transitions = Hash.new { |h, k| h[k] = Set.new }
          @fallback_transitions = Hash.new { |h, k| h[k] = Set.new }
          @free_transitions = Set.new
        end

        def add_transition(matcher, state)
          transitions[matcher] << state
        end

        def add_fallback_transition(matcher, state)
          fallback_transitions[matcher] << state
        end

        def add_free_transition(state)
          free_transitions << state
        end

        def follow(token)
          new_states = matching_transitions(token).
            map(&:freely_reachable).
            inject(Set.new, :|)

          if new_states.empty?
            fallback_states
          else
            new_states
          end
        end

        def accept_visitor(visitor, visited_states)
          unless visited_states.include?(self)
            visited_states << self
            visitor.visit_state(self)
            visit_free_transitions(visitor, visited_states)
            visit_transitions(visitor, visited_states)
          end
        end

        def freely_reachable
          free_transitions.map(&:freely_reachable).inject([self].to_set, :|)
        end

        def completions(token)
          all_matchers.flat_map { |matcher| matcher.completions(token) }
        end

        def inspect
          "<State:#{name}>"
        end

        private

        attr_reader :free_transitions, :fallback_transitions, :transitions

        def all_matchers
          transitions.keys + fallback_transitions.keys
        end

        def matching_transitions(token)
          transitions.inject(Set.new) do |matched_states, (matcher, states)|
            if matcher.match?(token)
              matched_states | states
            else
              matched_states
            end
          end
        end

        def fallback_states
          fallback_transitions.values.inject(Set.new, :|).
            map(&:freely_reachable).inject(Set.new, :|)
        end

        def visit_free_transitions(visitor, visited_states)
          free_transitions.each do |end_state|
            visitor.visit_free_transition(self, end_state)
            end_state.accept_visitor(visitor, visited_states)
          end
        end

        def visit_transitions(visitor, visited_states)
          transitions.each do |matcher, end_states|
            end_states.each do |end_state|
              visitor.visit_transition(self, end_state, matcher)
              end_state.accept_visitor(visitor, visited_states)
            end
          end
        end
      end
    end
  end
end
