require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class RevisionMatcher < BaseMatcher
        SEPARATORS = /(?:\.\.+|[:^~\\])/

        def initialize(env)
          @env = env
        end

        def name
          'revision'
        end

        def completions(token)
          prefix, partial_name = split(token)
          env.repo_heads.
            select { |option| option.start_with?(partial_name) }.
            map { |option| prefix + option }
        end

        private

        attr_reader :env

        def split(token)
          parts = token.rpartition(SEPARATORS)
          [parts[0...-1].join, parts[-1]]
        end
      end
    end
  end
end
