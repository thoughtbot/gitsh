require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/dsl'

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
        path = File.join(GITSH_CONFIG_DIRECTORY, 'completions')
        DSL.load(path, start_state, env)
        Automaton.new(start_state)
      end

      private

      attr_reader :env

      def start_state
        @start_state ||= Automaton::State.new('start')
      end
    end
  end
end
