require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class BranchMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :env

        def name
          'branch'
        end

        private

        def all_completions
          env.repo_branches
        end
      end
    end
  end
end
