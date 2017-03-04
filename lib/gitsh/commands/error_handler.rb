module Gitsh
  module Commands
    class ErrorHandler
      def initialize(command)
        @command = command
      end

      def execute(env)
        command.execute(env)
      rescue Gitsh::Error => error
        env.puts_error("gitsh: #{error.message}")
        false
      end

      private

      attr_reader :command
    end
  end
end
