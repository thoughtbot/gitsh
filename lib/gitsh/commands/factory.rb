require 'gitsh/argument_list'
require 'gitsh/commands/error_handler'

module Gitsh
  module Commands
    class Factory
      def self.build(*args)
        new(*args).build
      end

      def initialize(command_class, context)
        @command_class = command_class
        @context = context
      end 

      def build
        ErrorHandler.new(command_instance, env)
      end

      private

      attr_reader :command_class, :context

      def command_instance
        command_class.new(env, command, argument_list)
      end

      def argument_list
        ArgumentList.new(args)
      end

      def env
        context[:env]
      end

      def command
        context[:command]
      end

      def args
        context.fetch(:args, []).compact
      end
    end
  end
end
