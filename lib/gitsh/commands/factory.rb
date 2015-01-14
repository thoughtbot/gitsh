require 'gitsh/argument_list'

module Gitsh
  module Commands
    class Factory
      def initialize(command_class, context)
        @command_class = command_class
        @context = context
      end 

      def build
        command_class.new(env, command, argument_list)
      end

      private

      attr_reader :command_class, :context

      def argument_list
        ArgumentList.new(args)
      end

      def env
        context[:env]
      end

      def command
        context[:cmd]
      end

      def args
        context.fetch(:args, []).compact
      end
    end
  end
end
