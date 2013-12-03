module Gitsh
  module InternalCommand
    def self.new(env, command, args=[])
      klass = COMMAND_CLASSES.fetch(command.to_sym, Unknown)
      klass.new(env, command, args)
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
        else
          env.puts_error 'usage: :set variable value'
        end
      end

      private

      def valid_arguments?
        args.length == 2
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
      end
    end

    COMMAND_CLASSES = {
      set: Set,
      exit: Exit
    }.freeze
  end
end
