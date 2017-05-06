module Gitsh
  module TabCompletion
    module Matchers
      class BranchMatcher
        SEPARATORS = /(?:\.\.+|[:^~\\])/

        def initialize(env)
          @env = env
        end

        def name
          'branch'
        end

        def match?(_word)
          true
        end

        def completions(_token)
          env.repo_branches
        end

        private

        attr_reader :env
      end
    end
  end
end
