module Gitsh
  module TabCompletion
    module Matchers
      class AliasMatcher
        def initialize(env)
          @env = env
        end

        def match?(_word)
          true
        end

        def completions(_token)
          env.git_aliases
        end

        private

        attr_reader :env
      end
    end
  end
end
