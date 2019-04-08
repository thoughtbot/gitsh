require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TagMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :repo

        def name
          'tag'
        end

        private

        def all_completions
          repo.tags
        end
      end
    end
  end
end
