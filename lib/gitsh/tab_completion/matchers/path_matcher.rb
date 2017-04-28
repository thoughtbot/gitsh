require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class PathMatcher < BaseMatcher
        def completions(token)
          prefix = normalize_path(token)
          paths(prefix).map { |option| option.sub(prefix, token) }
        end

        private

        def normalize_path(token)
          if token.end_with?('/')
            File.expand_path(token) + '/'
          else
            File.expand_path(token)
          end
        end

        def paths(prefix)
          Dir["#{prefix}*"].map do |path|
            if File.directory?(path)
              path + '/'
            else
              path
            end
          end
        end
      end
    end
  end
end
