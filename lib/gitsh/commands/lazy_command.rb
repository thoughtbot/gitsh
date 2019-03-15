require 'gitsh/argument_list'
require 'gitsh/commands/git_command'
require 'gitsh/commands/internal_command'
require 'gitsh/commands/shell_command'

module Gitsh
  module Commands
    class LazyCommand
      COMMAND_PREFIX_MATCHER = /^([:!])?(.+)$/
      COMMAND_CLASS_BY_PREFIX = {
        nil => Gitsh::Commands::GitCommand,
        ':' => Gitsh::Commands::InternalCommand,
        '!' => Gitsh::Commands::ShellCommand,
      }.freeze

      def initialize(args = [])
        @args = args.compact
      end

      def execute(env)
        arg_values = argument_list.values(env)
        prefix, command = split_command(arg_values.shift)
        command_class(prefix).new(command, arg_values).execute(env)
      rescue Gitsh::Error => error
        env.puts_error("gitsh: #{error.message}")
        false
      end

      private

      attr_reader :args

      def command_class(prefix)
        COMMAND_CLASS_BY_PREFIX.fetch(prefix)
      end

      def split_command(command)
        COMMAND_PREFIX_MATCHER.match(command).values_at(1, 2)
      end

      def argument_list
        ArgumentList.new(args)
      end
    end
  end
end
