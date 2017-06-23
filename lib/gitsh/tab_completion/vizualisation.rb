require 'set'
require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/matchers/text_matcher'

module Gitsh
  module TabCompletion
    class Vizualisation
      def initialize(start_state)
        @start_state = start_state
      end

      def to_dot
        %Q(digraph TabCompletion {
          ranksep=3;
          nodesep=3;
          #{node_labels.join("\n  ")}
          #{free_transitions.join("\n  ")}
          #{transitions.join("\n  ")}
        })
      end

      def summary
        "#{node_labels.length} nodes\n"\
          "#{transitions.length + free_transitions.length} edges"
      end

      private

      attr_reader :start_state

      def node_labels
        @node_labels ||= states.map do |state|
          '%s [ label=%s ];' % [state_name(state), state.name.inspect]
        end
      end

      def transitions
        @transitions ||= states.inject([]) do |acc, state|
          acc + state.transitions.flat_map do |matcher, end_states|
            end_states.map do |end_state|
              '%s -> %s [ label=%s ];' % [
                state_name(state),
                state_name(end_state),
                transition_label(matcher).inspect,
              ]
            end
          end
        end
      end

      def free_transitions
        @free_transitions ||= states.inject([]) do |acc, state|
          acc + state.free_transitions.map do |end_state|
            '%s -> %s;' % [
              state_name(state),
              state_name(end_state),
            ]
          end
        end
      end

      def states
        @states ||= discover_states(Set.new([start_state]), Set.new)
      end

      def discover_states(states, previously_seen)
        seen = previously_seen | states

        states.each do |state|
          state.transitions.each do |_matcher, end_states|
            seen = discover_states(end_states - seen, seen)
          end

          state.free_transitions.each do |end_state|
            end_states = Set.new([end_state])
            seen = discover_states(end_states - seen, seen)
          end
        end

        seen
      end

      def state_name(state)
        state.object_id
      end

      def transition_label(matcher)
        case matcher
        when Gitsh::TabCompletion::Matchers::TextMatcher
          "\"#{matcher.word}\""
        else
          "$#{matcher.name}"
        end
      end
    end
  end
end
