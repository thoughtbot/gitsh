require 'gitsh/tab_completion/matchers/base_matcher'
require 'gitsh/commands/internal_command'

module Gitsh
  module TabCompletion
    module Matchers
      class CommandMatcher < BaseMatcher
        def initialize(env, internal_command = Commands::InternalCommand)
          @env = env
          @internal_command = internal_command
        end

        def name
          'command'
        end

        private

        attr_reader :env, :internal_command

        def all_completions
          env.git_commands + env.git_aliases + internal_command.commands
        end
      end
    end
  end
end
