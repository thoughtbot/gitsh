require 'gitsh/commands/internal_command'

module Gitsh
  class Completer
    def initialize(line_editor, env, internal_command=Commands::InternalCommand)
      @line_editor = line_editor
      @env = env
      @internal_command = internal_command
    end

    def call(input)
      InputCompleter.new(input, @line_editor, @env, @internal_command).call
    end

    class InputCompleter
      def initialize(input, line_editor, env, internal_command)
        @input = input
        @line_editor = line_editor
        @env = env
        @internal_command = internal_command
      end

      def call
        line_editor.completion_append_character = completion_append_character
        line_editor.completion_suppress_quote = incomplete_path?

        matches
      end

      private

      attr_reader :input, :line_editor, :env, :internal_command

      def completion_append_character
        if incomplete_path?
          nil
        else
          ' '
        end
      end

      def incomplete_path?
        matches.size == 1 && matches.first.end_with?('/')
      end

      def matches
        @_matches ||= available_completers.flat_map(&:completions)
      end

      def available_completers
        if completing_arguments?
          [heads, paths, remotes]
        else
          [commands]
        end
      end

      def completing_arguments?
        full_input = line_editor.line_buffer
        tokens = full_input.split
        tokens.any? && full_input.end_with?(' ') || tokens.size > 1
      end

      def commands
        CommandCompleter.new(input, env, internal_command)
      end

      def heads
        HeadCompleter.new(input, env)
      end

      def paths
        PathCompleter.new(input)
      end

      def remotes
        RemoteCompleter.new(input, env)
      end

      class TextCompleter
        def initialize(input)
          @input = input
        end

        def completions
          collection.
            select { |option| option.start_with?(matchable_input) }.
            map { |option| option.sub(matchable_input, input) }
        end

        private

        attr_reader :input
      end

      class HeadCompleter < TextCompleter
        SEPARATORS = /(?:\.\.+|[:^~\\])/

        def initialize(input, env)
          super(input)
          @env = env
        end

        private

        attr_reader :env

        def collection
          env.repo_heads
        end

        def matchable_input
          input.split(SEPARATORS, -1).last || ''
        end
      end

      class PathCompleter < TextCompleter
        private

        def collection
          Dir["#{matchable_input}*"].map do |path|
            if File.directory?(path)
              path + '/'
            else
              path
            end
          end
        end

        def matchable_input
          if input.end_with?('/')
            File.expand_path(input) + '/'
          else
            File.expand_path(input)
          end
        end
      end

      class CommandCompleter < TextCompleter
        def initialize(input, env, internal_command)
          super(input)
          @env = env
          @internal_command = internal_command
        end

        private

        attr_reader :env, :internal_command

        def collection
          env.git_commands + env.git_aliases + internal_command.commands
        end

        def matchable_input
          input
        end
      end

      class RemoteCompleter < TextCompleter
        def initialize(input, env)
          super(input)
          @env = env
        end

        private

        attr_reader :env

        def collection
          env.repo_remotes
        end

        def matchable_input
          input
        end
      end
    end
  end
end
