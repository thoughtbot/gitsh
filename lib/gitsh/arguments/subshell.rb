require 'gitsh/capturing_environment'
require 'gitsh/string_runner'

module Gitsh
  module Arguments
    class Subshell
      def initialize(command, options = {})
        @command = command
      end

      def value(env)
        capturing_env = CapturingEnvironment.new(env.clone)
        StringRunner.run(env: capturing_env, command: command)
        strip_whitespace(capturing_env.captured_output)
      end

      private

      attr_reader :command

      def strip_whitespace(output)
        output.
          sub(%r{\r?\n\Z}, '').
          gsub(%r{[\n\r\s]+}, ' ')
      end
    end
  end
end
