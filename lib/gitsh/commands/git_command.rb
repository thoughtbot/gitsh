require 'shellwords'
require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class GitCommand
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
        if autocorrect_enabled? && command == 'git'
          [git_command, config_arguments, arg_values].flatten
        else
          [git_command, config_arguments, command, arg_values].flatten
        end
      end

      def git_command
        Shellwords.split(env.git_command)
      end

      def config_arguments
        env.config_variables.map { |k, v| ['-c', "#{k}=#{v}"] }
      end

      def arg_values
        args.values(env)
      end

      def autocorrect_enabled?
        env.fetch('help.autocorrect') { '0' } != '0'
      end
    end
  end
end
