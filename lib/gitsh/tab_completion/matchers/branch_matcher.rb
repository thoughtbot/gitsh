require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class BranchMatcher < BaseMatcher
        def name
          'branch'
        end

        private

        def all_completions
          env.repo_branches
        end

        def env
          Registry.env
        end
      end
    end
  end
end
