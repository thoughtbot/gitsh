require 'gitsh/tab_completion/matchers/revision_matcher'
require 'gitsh/tab_completion/matchers/path_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class TreeishMatcher
        def initialize(env)
          @env = env
        end

        def name
          'treeish'
        end

        def match?(word)
          !word.start_with?('-')
        end

        def completions(token)
          if should_complete_path?(token)
            paths(token)
          else
            revisions_and_paths(token)
          end
        end

        private

        attr_reader :env

        def should_complete_path?(token)
          token.include?(':')
        end

        def revisions_and_paths(token)
          revision_matcher.completions(token) + path_matcher.completions(token)
        end

        def paths(token)
          prefix, _, path_token = token.rpartition(':')
          path_matcher.completions(path_token).map do |path|
            "#{prefix}:#{path}"
          end
        end

        def revision_matcher
          @revision_matcher ||= RevisionMatcher.new(env)
        end

        def path_matcher
          @path_matcher ||= PathMatcher.new(env)
        end
      end
    end
  end
end
