require 'gitsh/registry'
require 'gitsh/tab_completion/automaton'
require 'gitsh/tab_completion/dsl'

module Gitsh
  module TabCompletion
    class AutomatonFactory
      def self.build
        new.build
      end

      def build
        start_state = Automaton::State.new('start')
        config_paths.each do |path|
          DSL.load(path, start_state)
        end
        Automaton.new(start_state)
      end

      private

      def config_paths
        [
          File.join(env.config_directory, 'completions'),
          File.join(ENV.fetch('HOME', '/'), '.gitsh_completions'),
        ]
      end

      def env
        Registry.env
      end
    end
  end
end
