require 'gitsh/git_repository'
require 'gitsh/colors'

module Gitsh
  class Prompter
    DEFAULT_FORMAT = '%b%#'.freeze

    def initialize(options={}, repo=GitRepository.new)
      @repo = repo
      @options = options
    end

    def prompt
      padded_prompt_format.gsub(/%[bdD#]/, {
        '%b' => branch_name,
        '%d' => Dir.getwd,
        '%D' => File.basename(Dir.getwd),
        '%#' => terminator
      })
    end

    private

    attr_reader :repo

    def padded_prompt_format
      "#{prompt_format.chomp} "
    end

    def prompt_format
      repo.config('gitsh.prompt') || DEFAULT_FORMAT
    end

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
