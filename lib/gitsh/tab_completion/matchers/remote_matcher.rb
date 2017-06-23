require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class RemoteMatcher < BaseMatcher
        def initialize(env)
          @env = env
        end

        def name
          'remote'
        end

        private

        attr_reader :env

        def all_completions
          env.repo_remotes
        end
      end
    end
  end
end
