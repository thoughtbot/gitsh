require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TagMatcher < BaseMatcher
        def initialize(env)
          @env = env
        end

        def name
          'tag'
        end

        private

        attr_reader :env

        def all_completions
          env.repo_tags
        end
      end
    end
  end
end
