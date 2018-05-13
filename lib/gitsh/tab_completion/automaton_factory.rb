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
        start_state = Automaton::State.new('start')
        config_paths.each do |path|
          DSL.load(path, start_state, env)
        end
        Automaton.new(start_state)
      end

      private

      attr_reader :env

      def config_paths
        [
          File.join(env.config_directory, 'completions'),
          File.join(ENV.fetch('HOME', '/'), '.gitsh_completions'),
        ]
      end
    end
  end
end
