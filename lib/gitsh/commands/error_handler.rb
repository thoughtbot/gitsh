module Gitsh
  module Commands
    class ErrorHandler
      def initialize(command, env)
        @command = command
        @env = env
      end

      def execute
        command.execute
      rescue Gitsh::Error => error
        env.puts_error("gitsh: #{error.message}")
        false
      end

      private

      attr_reader :command, :env
    end
  end
end
