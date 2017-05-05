require 'gitsh/commands/internal_command'
require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/matchers/command_matcher'
require 'gitsh/tab_completion/matchers/path_matcher'
require 'gitsh/tab_completion/matchers/remote_matcher'
require 'gitsh/tab_completion/matchers/revision_matcher'

module Gitsh
  module TabCompletion
    class AutomatonFactory
      def self.build(env)
        new(env).build
      end

      def initialize(env)
        @env = env
      end

      def build
        Automaton.new(start_state)
      end

      private

      attr_reader :env

      def start_state
        start_state = Automaton::State.new('start')

        command_state = Automaton::State.new('command')
        start_state.add_transition(
          Matchers::CommandMatcher.new(env, Commands::InternalCommand),
          command_state
        )

        command_state.add_transition(
          Matchers::RevisionMatcher.new(env),
          command_state,
        )
        command_state.add_transition(
          Matchers::PathMatcher.new(env),
          command_state,
        )
        command_state.add_transition(
          Matchers::RemoteMatcher.new(env),
          command_state,
        )

        start_state
      end
    end
  end
end
