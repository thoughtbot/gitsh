require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TagMatcher < BaseMatcher
        def name
          'tag'
        end

        private

        def all_completions
          env.repo_tags
        end

        def env
          Registry.env
        end
      end
    end
  end
end
