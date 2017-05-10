module Gitsh
  module TabCompletion
    module Matchers
      class TagMatcher
        def initialize(env)
          @env = env
        end

        def name
          'tag'
        end

        def match?(_word)
          true
        end

        def completions(_token)
          env.repo_tags
        end

        private

        attr_reader :env
      end
    end
  end
end
