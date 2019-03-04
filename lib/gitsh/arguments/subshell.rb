require 'gitsh/capturing_environment'

module Gitsh
  module Arguments
    class Subshell
      def initialize(command, options = {})
        @command = command
      end

      def value(env)
        capturing_env = CapturingEnvironment.new(env.clone)
        command.execute(capturing_env)
        [strip_whitespace(capturing_env.captured_output)]
      end

      def ==(other)
        other.is_a?(self.class) && command == other.command
      end

      protected

      attr_reader :command

      private

      def strip_whitespace(output)
        output.
          sub(%r{\r?\n\Z}, '').
          gsub(%r{\s+}, ' ')
      end
    end
  end
end
