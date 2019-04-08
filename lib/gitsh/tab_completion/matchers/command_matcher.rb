require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'
require 'gitsh/commands/internal_command'

module Gitsh
  module TabCompletion
    module Matchers
      class CommandMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :env, :repo

        def initialize(internal_command = Commands::InternalCommand)
          @internal_command = internal_command
        end

        def name
          'command'
        end

        private

        attr_reader :internal_command

        def all_completions
          repo.commands + \
            repo.aliases + \
            env.local_aliases + \
            internal_command.commands
        end
      end
    end
  end
end
