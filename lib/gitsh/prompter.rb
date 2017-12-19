# encoding: utf-8

require 'gitsh/colors'
require 'gitsh/prompt_color'

module Gitsh
  class Prompter
    DEFAULT_FORMAT = "%D %c%B%#%w".freeze
    BRANCH_CHAR_LIMIT = 15

    def initialize(options={})
      @env = options.fetch(:env)
      @use_color = options.fetch(:color, true)
      @prompt_color = options.fetch(:prompt_color) { PromptColor.new(@env) }
      @options = options
    end

    def prompt
      Prompt.new(env, use_color, prompt_color).to_s
    end

    private

    attr_reader :env, :use_color, :prompt_color

    class Prompt
      def initialize(env, use_color, prompt_color)
        @env = env
        @use_color = use_color
        @prompt_color = prompt_color
      end

      def to_s
        padded_prompt_format.gsub(/%[bBcdDgGw#]/) do |match|
          case match
          when "%b" then branch_name
          when "%B" then shortened_branch_name
          when "%c" then status_color
          when "%d" then working_directory
          when "%D" then File.basename(working_directory)
          when "%g" then git_command
          when "%G" then File.basename(git_command)
          when "%w" then clear_color
          when "%#" then terminator
          end
        end
      end

      private

      attr_reader :env, :prompt_color

      def working_directory
        Dir.getwd.sub(/\A#{Dir.home}/, '~')
      end

      def padded_prompt_format
        "#{prompt_format.chomp} "
      end

      def prompt_format
        env.fetch('gitsh.prompt') { DEFAULT_FORMAT }
      end

      def shortened_branch_name
        branch_name[0...BRANCH_CHAR_LIMIT] + ellipsis
      end

      def ellipsis
        if branch_name.length > BRANCH_CHAR_LIMIT
          '…'
        else
          ''
        end
      end

      def branch_name
        @branch_name ||= if repo_status.initialized?
          env.repo_current_head
        else
          'uninitialized'
        end
      end

      def git_command
        env.git_command
      end

      def terminator
        if !repo_status.initialized?
          '!!'
        elsif repo_status.has_untracked_files?
          '!'
        elsif repo_status.has_modified_files?
          '&'
        else
          '@'
        end
      end

      def status_color
        if use_color?
          prompt_color.status_color(repo_status)
        else
          Colors::NONE
        end
      end

      def clear_color
        if use_color?
          Colors::CLEAR
        else
          Colors::NONE
        end
      end

      def use_color?
        @use_color
      end

      def repo_status
        @repo_status ||= env.repo_status
      end
    end
  end
end
