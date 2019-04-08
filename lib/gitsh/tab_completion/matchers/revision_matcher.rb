require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class RevisionMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :repo

        SEPARATORS = /(?:\.\.+|[:^~\\])/

        def name
          'revision'
        end

        def completions(token)
          prefix, partial_name = split(token)
          super(partial_name).map { |option| prefix + option }
        end

        private

        def all_completions
          repo.heads
        end

        def split(token)
          parts = token.rpartition(SEPARATORS)
          [parts[0...-1].join, parts[-1]]
        end
      end
    end
  end
end
