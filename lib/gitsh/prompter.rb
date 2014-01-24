require 'gitsh/colors'

module Gitsh
  class Prompter
    DEFAULT_FORMAT = '%D %b%c%#%w'.freeze

    def initialize(options={})
      @env = options.fetch(:env)
      @options = options
    end

    def prompt
      if use_color?
        prompt_with_color
      else
        Colors.strip_color_codes(prompt_with_color)
      end
    end

    private

    attr_reader :env

    def prompt_with_color
      padded_prompt_format.gsub(/%[bcdDw#]/, {
        '%b' => branch_name,
        '%c' => status_color,
        '%d' => Dir.getwd,
        '%D' => File.basename(Dir.getwd),
        '%w' => Colors::CLEAR,
        '%#' => terminator
      })
    end

    def padded_prompt_format
      "#{prompt_format.chomp} "
    end

    def prompt_format
      env.fetch('gitsh.prompt', DEFAULT_FORMAT)
    end

    def branch_name
      if env.repo_initialized?
        env.repo_current_head
      else
        'uninitialized'
      end
    end

    def terminator
      if !env.repo_initialized?
        '!!'
      elsif env.repo_has_untracked_files?
        '!'
      elsif env.repo_has_modified_files?
        '&'
      else
        '@'
      end
    end

    def status_color
      if !env.repo_initialized?
        Colors::RED_BG
      elsif env.repo_has_untracked_files?
        Colors::RED_FG
      elsif env.repo_has_modified_files?
        Colors::ORANGE_FG
      else
        Colors::BLUE_FG
      end
    end

    def use_color?
      @options.fetch(:color, true)
    end
  end
end
