require 'gitsh/registry'
require 'gitsh/tab_completion/matchers/base_matcher'

module Gitsh
  module TabCompletion
    module Matchers
      class RemoteMatcher < BaseMatcher
        extend Registry::Client
        use_registry_for :env

        def name
          'remote'
        end

        private

        def all_completions
          env.repo_remotes
        end
      end
    end
  end
end
