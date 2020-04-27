require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'
require 'gitsh/commands/internal_command'

module Gitsh
  module TabCompletion
    module Matchers
      class CommandMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :env, :repo

        def name
          'command'
        end

        private

        def all_completions
          repo.commands + \
            repo.aliases + \
            env.local_aliases + \
            Commands::InternalCommand.commands
        end
      end
    end
  end
end
