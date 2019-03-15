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

      def initialize(command:, args: [])
        @prefix, @command = COMMAND_PREFIX_MATCHER.match(command).values_at(1, 2)
        @args = args.compact
      end

      def execute(env)
        command_instance.execute(env)
      rescue Gitsh::Error => error
        env.puts_error("gitsh: #{error.message}")
        false
      end

      private

      attr_reader :command, :args, :prefix

      def command_instance
        command_class.new(command, argument_list)
      end

      def command_class
        COMMAND_CLASS_BY_PREFIX.fetch(prefix)
      end

      def argument_list
        ArgumentList.new(args)
      end
    end
  end
end
