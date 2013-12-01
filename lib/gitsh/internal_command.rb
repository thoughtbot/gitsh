module Gitsh
  module InternalCommand
    def self.new(env, command, args=[])
      if klass = COMMAND_CLASSES[command.to_sym]
        klass.new(env, args)
      end
    end

    class Set
      def initialize(env, args=[])
        @env = env
        @args = args
      end

      def execute
        if valid_arguments?
          key, value = args
          env[key] = value
        else
          env.puts_error 'usage: :set variable value'
        end
      end

      private

      attr_reader :env, :args

      def valid_arguments?
        args.length == 2
      end
    end

    COMMAND_CLASSES = {
      set: Set
    }.freeze
  end
end
