require 'gitsh/git_repository'

module Gitsh
  class Completer
    def initialize(readline, repo = Gitsh::GitRepository.new)
      @readline = readline
      @repo = repo
    end

    def call(input)
      InputCompleter.new(input, @readline, @repo).complete
    end

    class InputCompleter
      def initialize(input, readline, repo)
        @input = input
        @readline = readline
        @repo = repo
      end

      def complete
        available_completions.select { |option| option.start_with?(input) }
      end

      private

      attr_reader :input, :readline, :repo

      def available_completions
        if completing_arguments?
          repo.heads.map { |head| "#{head} " } + paths
        else
          (repo.commands + repo.aliases).map { |cmd| "#{cmd} " }
        end
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
