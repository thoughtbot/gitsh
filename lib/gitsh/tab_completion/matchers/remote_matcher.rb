require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class RemoteMatcher < BaseMatcher
        def name
          'remote'
        end

        private

        def all_completions
          env.repo_remotes
        end

        def env
          Registry.env
        end
      end
    end
  end
end
