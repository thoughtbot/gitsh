require 'gitsh/git_repository'
require 'gitsh/internal_command'

module Gitsh
  class Completer
    def initialize(readline, repo=GitRepository.new, internal_command=InternalCommand)
      @readline = readline
      @repo = repo
      @internal_command = internal_command
    end

    def call(input)
      InputCompleter.new(input, @readline, @repo, @internal_command).complete
    end

    class InputCompleter
      def initialize(input, readline, repo, internal_command)
        @input = input
        @readline = readline
        @repo = repo
        @internal_command = internal_command
      end

      def complete
        available_completions.select { |option| option.start_with?(input) }
      end

      private

      attr_reader :input, :readline, :repo, :internal_command

      def available_completions
        if completing_arguments?
          repo.heads.map { |head| "#{head} " } + paths
        else
          commands.map { |cmd| "#{cmd} " }
        end
      end

      def commands
        repo.commands + repo.aliases + internal_command.commands
      end

      def completing_arguments?
        full_input = readline.line_buffer
        tokens = full_input.split
        tokens.any? && full_input.end_with?(' ') || tokens.size > 1
      end

      def paths
        Dir["#{input}*"].map do |path|
          if File.directory?(path)
            "#{path}/"
          else
            "#{path} "
          end
        end
      end
    end
  end
end
