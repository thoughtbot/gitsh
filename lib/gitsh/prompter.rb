require 'gitsh/git_repository'

module Gitsh
  class Prompter
    def initialize(repo=GitRepository.new)
      @repo = repo
    end

    def prompt
      "#{branch_name}#{terminator} "
    end

    private

    attr_reader :repo

    def branch_name
      if repo.initialized?
        repo.current_head
      else
        'uninitialized'
      end
    end

    def terminator
      if !repo.initialized?
        '!!'
      elsif repo.has_untracked_files?
        '!'
      elsif repo.has_modified_files?
        '&'
      else
        '@'
      end
    end
  end
end
