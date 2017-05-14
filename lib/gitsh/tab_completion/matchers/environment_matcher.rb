require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class EnvironmentMatcher < BaseMatcher
        attr_reader :name

        def initialize(env, name, &block)
          @env = env
          @name = name
          @block = block
        end

        def eql?(other)
          super && name == other.name
        end

        def hash
          super + name.hash
        end

        private

        attr_reader :env, :block

        def all_completions
          block.call(env)
        end
      end
    end
  end
end
