module Gitsh
  module TabCompletion
    module Matchers
      class AnythingMatcher
        def initialize(_env)
        end

        def match?(_word)
          true
        end

        def completions(_token)
          []
        end
      end
    end
  end
end
