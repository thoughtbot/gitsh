require 'shellwords'
require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class GitCommand
      def initialize(command, arg_values, options = {})
        @command = command
        @arg_values = arg_values
        @shell_command_runner = options.fetch(
          :shell_command_runner,
          ShellCommandRunner,
        )
      end

      def execute(env)
        shell_command_runner.run(command_with_arguments(env), env)
      end

      private

      attr_reader :command, :arg_values, :shell_command_runner

      def command_with_arguments(env)
        if autocorrect_enabled?(env) && command == 'git'
          [git_command(env), config_arguments(env), arg_values].flatten
        else
          [git_command(env), config_arguments(env), command, arg_values].flatten
        end
      end

      def git_command(env)
        Shellwords.split(env.git_command)
      end

      def config_arguments(env)
        env.config_variables.map { |k, v| ['-c', "#{k}=#{v}"] }
      end

      def autocorrect_enabled?(env)
        env.fetch('help.autocorrect') { '0' } != '0'
      end
    end
  end
end
