module Gitsh
  module TabCompletion
    module Matchers
      class BaseMatcher
        def match?(_)
          true
        end

        def completions(token)
          all_completions.select { |option| option.start_with?(token) }
        end

        def eql?(other)
          self.class == other.class
        end

        def hash
          self.class.hash + 1
        end

        private

        def all_completions
          []
        end
      end
    end
  end
end
