require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class UnknownOptionMatcher < BaseMatcher
        def match?(word)
          word =~ /\A--?[^-]/
        end

        def name
          'opt'
        end
      end
    end
  end
end
