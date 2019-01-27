require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class BranchMatcher < BaseMatcher
        def initialize(env)
          @env = env
        end

        def name
          'branch'
        end

        private

        attr_reader :env

        def all_completions
          env.repo_branches
        end
      end
    end
  end
end
