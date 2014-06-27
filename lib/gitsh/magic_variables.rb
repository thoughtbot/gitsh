module Gitsh
  class MagicVariables
    def initialize(repo)
      @repo = repo
    end

    def [](key)
      if available_variables.include?(key)
        send(key)
      end
    end

    private

    attr_reader :repo

    def available_variables
      private_methods(false).grep(/^_/)
    end

    def _prior
      repo.revision_name('@{-1}')
    end

    def _merge_base
      repo.merge_base('HEAD', 'MERGE_HEAD')
    end

    def _rebase_base
      File.read(File.join(repo.git_dir, 'rebase-apply', 'onto')).chomp
    rescue Errno::ENOENT
      nil
    end
  end
end
