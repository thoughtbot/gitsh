module Gitsh
  module InputStrategies
    class String
      def initialize(opts)
        @command = opts.fetch(:command)
      end

      def setup
        @commands = [command].each
      end

      def teardown
      end

      def read_command
        commands.next
      rescue StopIteration
        nil
      end

      private

      attr_reader :commands, :command
    end
  end
end
