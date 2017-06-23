require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class CommandMatcher < BaseMatcher
        def initialize(env, internal_command)
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
