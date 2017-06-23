require 'set'
require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/matchers/text_matcher'

module Gitsh
  module TabCompletion
    class Visualization
      def initialize(automaton)
        @automaton = automaton
      end

      def to_dot
        %Q(digraph TabCompletion {
          ranksep=3;
          nodesep=3;
          #{visitor.node_labels.join("\n  ")}
          #{visitor.transitions.join("\n  ")}
        })
      end

      def summary
        "#{visitor.node_labels.length} nodes\n"\
          "#{visitor.transitions.length} edges"
      end

      private

      attr_reader :automaton

      def visitor
        @visitor ||= Visitor.new.tap do |visitor|
          automaton.accept_visitor(visitor)
        end
      end

      class Visitor
        attr_reader :node_labels, :transitions

        def initialize
          @node_labels = []
          @transitions = []
        end

        def visit_state(state)
          node_labels << '%s [ label=%s ];' % [
            state_identifier(state),
            state.name.inspect,
          ]
        end

        def visit_transition(start_state, end_state, matcher)
          transitions << '%s -> %s [ label=%s ];' % [
            state_identifier(start_state),
            state_identifier(end_state),
            transition_label(matcher).inspect,
          ]
        end

        def visit_free_transition(start_state, end_state)
          transitions << '%s -> %s;' % [
            state_identifier(start_state),
            state_identifier(end_state),
          ]
        end

        private

        def state_identifier(state)
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
end
