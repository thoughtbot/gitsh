require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class ShellCommand
      SHELLWORDS_WHITELIST = 'A-Za-z0-9_\-.,:\/@\n'.freeze
      GLOB_WHITELIST = '\*\[\]!\?\\\\'.freeze
      SHELL_CHARACTER_FILTER = /([^#{SHELLWORDS_WHITELIST}#{GLOB_WHITELIST}])/

      def initialize(command, arg_values, options = {})
        @command = command
        @arg_values = arg_values
        @shell_command_runner = options.fetch(
          :shell_command_runner,
          ShellCommandRunner,
        )
      end

      def execute(env)
        shell_command_runner.run(command_with_arguments, env)
      end

      private

      attr_reader :command, :arg_values, :shell_command_runner

      def command_with_arguments
        [
          '/bin/sh',
          '-c',
          [command, escaped_arg_values].flatten.join(' '),
        ]
      end

      def escaped_arg_values
        arg_values.map do |arg|
          arg.gsub(SHELL_CHARACTER_FILTER, '\\\\\\1')
        end
      end
    end
  end
end
