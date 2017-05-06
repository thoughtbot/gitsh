require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class CommandMatcher < BaseMatcher
        def initialize(env)
          @env = env
        end

        def name
          'command'
        end

        private

        attr_reader :env

        def all_completions
          env.git_commands
        end
      end
    end
  end
end
