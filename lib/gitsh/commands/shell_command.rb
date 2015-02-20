require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class ShellCommand
      def initialize(env, command, args, options = {})
        @env = env
        @command = command
        @args = args
        @shell_command_runner = options.fetch(
          :shell_command_runner,
          ShellCommandRunner,
        )
      end

      def execute
        shell_command_runner.run(command_with_arguments, env)
      end

      private

      attr_reader :env, :command, :args, :shell_command_runner

      def command_with_arguments
        [command, arg_values].flatten
      end

      def arg_values
        args.values(env)
      end
    end
  end
end
