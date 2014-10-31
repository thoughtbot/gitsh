require 'gitsh/capturing_environment'

module Gitsh
  module Arguments
    class Subshell
      def initialize(command, options = {})
        @command = command
        @interpreter_factory = options.fetch(:interpreter_factory)
      end

      def value(env)
        capturing_env = CapturingEnvironment.new(env.clone)
        interpreter_factory.new(capturing_env).execute(command)
        strip_whitespace(capturing_env.captured_output)
      end

      private

      attr_reader :command, :interpreter_factory

      def strip_whitespace(output)
        output.
          sub(%r{\r?\n\Z}, '').
          gsub(%r{[\n\r\s]+}, ' ')
      end
    end
  end
end
