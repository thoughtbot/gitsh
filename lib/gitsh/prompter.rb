require 'gitsh/git_repository'
require 'gitsh/colors'

module Gitsh
  class Prompter
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
        add_color('!!', Colors::RED_BG)
      elsif repo.has_untracked_files?
        add_color('!', Colors::RED_FG)
      elsif repo.has_modified_files?
        add_color('&', Colors::ORANGE_FG)
      else
        '@'
      end
    end

    def add_color(str, color)
      if use_color?
        "#{color}#{str}#{Colors::CLEAR}"
      else
        str
      end
    end

    def use_color?
      @options.fetch(:color, true)
    end
  end
end
