require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class AnythingMatcher < BaseMatcher
        def name
          'anything'
        end
      end
    end
  end
end
