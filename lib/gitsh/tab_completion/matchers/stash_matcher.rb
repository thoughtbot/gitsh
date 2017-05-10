module Gitsh
  module TabCompletion
    module Matchers
      class StashMatcher
        def initialize(env)
          @env = env
        end

        def name
          'stash'
        end

        def match?(_word)
          true
        end

        def completions(_token)
          env.repo_stashes
        end

        private

        attr_reader :env
      end
    end
  end
end
