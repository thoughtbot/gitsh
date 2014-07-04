require 'gitsh/commands/internal_command'

module Gitsh
  class Completer
    def initialize(readline, env, internal_command=Commands::InternalCommand)
      @readline = readline
      @env = env
      @internal_command = internal_command
    end

    def call(input)
      InputCompleter.new(input, @readline, @env, @internal_command).complete
    end

    class InputCompleter
      def initialize(input, readline, env, internal_command)
        @input = input
        @readline = readline
        @env = env
        @internal_command = internal_command
      end

      def complete
        available_completers.flat_map(&:completions).map { |arg| escape(arg) }
      end

      private

      attr_reader :input, :readline, :env, :internal_command

      def available_completers
        if completing_arguments?
          [heads, paths, remotes]
        else
          [commands]
        end
      end

      def escape(arg)
        if completing_quoted_argument?
          arg.strip
        else
          arg.gsub(/ (?!$)/, '\ ')
        end
      end

      def completing_arguments?
        tokens = full_input.split
        tokens.any? && full_input.end_with?(' ') || tokens.size > 1
      end

      def completing_quoted_argument?
        @_quoted ||= input_before_current_argument.end_with?('"', "'")
      end

      def input_before_current_argument
        full_input[0...-input.length]
      end

      def full_input
        readline.line_buffer
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
            map { |option| option.sub(matchable_input, input) + suffix(option) }
        end

        private

        attr_reader :input

        def suffix(_)
          ' '
        end
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
          Dir["#{matchable_input}*"]
        end

        def suffix(path)
          if File.directory?(path)
            '/'
          else
            ' '
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
