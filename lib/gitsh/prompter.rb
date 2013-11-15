require 'gitsh/git_repository'

module Gitsh
  class Prompter
    COLOR_RED_FG = "\033[00;31m"
    COLOR_ORANGE_FG = "\033[00;33m"
    COLOR_RED_BG = "\033[00;41m"
    COLOR_CLEAR = "\033[00m"

    def initialize(options={}, repo=GitRepository.new)
      @repo = repo
      @options = options
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
        add_color('!!', COLOR_RED_BG)
      elsif repo.has_untracked_files?
        add_color('!', COLOR_RED_FG)
      elsif repo.has_modified_files?
        add_color('&', COLOR_ORANGE_FG)
      else
        '@'
      end
    end

    def add_color(str, color)
      if use_color?
        "#{color}#{str}#{COLOR_CLEAR}"
      else
        str
      end
    end

    def use_color?
      @options.fetch(:color, true)
    end
  end
end
