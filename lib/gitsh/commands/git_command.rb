require 'shellwords'
require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class GitCommand
      def initialize(command, args, options = {})
        @command = command
        @args = args
        @shell_command_runner = options.fetch(
          :shell_command_runner,
          ShellCommandRunner,
        )
      end

      def execute(env)
        shell_command_runner.run(command_with_arguments(env), env)
      end

      private

      attr_reader :command, :args, :shell_command_runner

      def command_with_arguments(env)
        if autocorrect_enabled?(env) && command == 'git'
          [git_command(env), config_arguments(env), arg_values(env)].flatten
        else
          [git_command(env), config_arguments(env), command, arg_values(env)].flatten
        end
      end

      def git_command(env)
        Shellwords.split(env.git_command)
      end

      def config_arguments(env)
        env.config_variables.map { |k, v| ['-c', "#{k}=#{v}"] }
      end

      def arg_values(env)
        args.values(env)
      end

      def autocorrect_enabled?(env)
        env.fetch('help.autocorrect') { '0' } != '0'
      end
    end
  end
end
