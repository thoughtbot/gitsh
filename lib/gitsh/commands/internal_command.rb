module Gitsh::Commands
  module InternalCommand
    def self.new(env, command, args=[])
      klass = COMMAND_CLASSES.fetch(command.to_sym, Unknown)
      klass.new(env, command, args)
    end

    def self.commands
      COMMAND_CLASSES.keys.map { |key| ":#{key}" }
    end

    class Base
      def initialize(env, command, args=[])
        @env = env
        @command = command
        @args = args
      end

      def execute
        raise NotImplementedError,
          'InternalCommand::Base subclasses must provide an #execute method'
      end

      private

      attr_reader :env, :command, :args
    end

    class Set < Base
      def execute
        if valid_arguments?
          key, value = args
          env[key] = value
          true
        else
          env.puts_error 'usage: :set variable value'
          false
        end
      end

      private

      def valid_arguments?
        args.length == 2
      end
    end

    class Echo < Base
      def execute
        env.puts args.join(' ')
        true
      end
    end

    class Chdir < Base
      def execute
        if valid_arguments?
          change_directory
        else
          env.puts_error 'usage: :cd path'
          false
        end
      end

      private

      def valid_arguments?
        args.length == 1
      end

      def change_directory
        Dir.chdir(path)
      rescue Errno::ENOENT
        env.puts_error 'gitsh: cd: No such directory'
        false
      rescue Errno::ENOTDIR
        env.puts_error 'gitsh: cd: Not a directory'
        false
      end

      def path
        File.expand_path(args.first)
      end
    end

    class Exit < Base
      def execute
        exit
      end
    end

    class Unknown < Base
      def execute
        env.puts_error("gitsh: #{command}: command not found")
        false
      end
    end

    COMMAND_CLASSES = {
      set: Set,
      cd: Chdir,
      exit: Exit,
      echo: Echo,
    }.freeze
  end
end
