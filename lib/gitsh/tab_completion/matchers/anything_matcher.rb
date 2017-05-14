module Gitsh
  module TabCompletion
    module Matchers
      class AnythingMatcher
        def initialize(_env)
        end

        def name
          'anything'
        end

        def match?(word)
          !word.start_with?('-')
        end

        def completions(_token)
          []
        end
      end
    end
  end
end
