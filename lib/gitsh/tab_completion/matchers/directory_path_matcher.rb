require 'gitsh/tab_completion/matchers/path_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class DirectoryPathMatcher < PathMatcher
        def name
          'dir_path'
        end

        def completions(token)
          super.select { |path| path.end_with?('/') }
        end
      end
    end
  end
end
