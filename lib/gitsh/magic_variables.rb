module Gitsh
  class MagicVariables
    def initialize(repo)
      @repo = repo
    end

    def fetch(key)
      if available_variables.include?(key)
        send(key)
      else
        yield
      end
    end

    def available_variables
      private_methods(false).grep(/^_/)
    end

    private

    attr_reader :repo

    def _prior
      repo.revision_name('@{-1}') ||
        raise(UnsetVariableError, 'No prior branch')
    end

    def _merge_base
      repo.merge_base('HEAD', 'MERGE_HEAD').tap do |merge_base|
        if merge_base.empty?
          raise UnsetVariableError, 'No merge in progress'
        end
      end
    end

    def _rebase_base
      read_file(['rebase-apply', 'onto']) ||
        read_file(['rebase-merge', 'onto']) ||
        raise(UnsetVariableError, 'No rebase in progress')
    end

    def _root
      repo.root_dir.tap do |root_dir|
        if root_dir.empty?
          raise(UnsetVariableError, 'Not a Git repository')
        end
      end
    end

    def read_file(path_components)
      File.read(File.join(repo.git_dir, *path_components)).chomp
    rescue Errno::ENOENT
      nil
    end
  end
end
