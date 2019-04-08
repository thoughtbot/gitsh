require 'gitsh/error'
require 'gitsh/registry'

module Gitsh
  module InputStrategies
    class File
      extend Registry::Client
      use_registry_for :env

      STDIN_PLACEHOLDER = '-'.freeze

      def initialize(opts)
        @path = opts.fetch(:path)
      end

      def setup
        @file = open_file
      rescue Errno::ENOENT
        raise NoInputError, "#{path}: No such file or directory"
      rescue Errno::EACCES
        raise NoInputError, "#{path}: Permission denied"
      end

      def teardown
        if file
          file.close
        end
      end

      def read_command
        next_line
      rescue EOFError
        nil
      end

      def read_continuation
        next_line
      end

      def handle_parse_error(message)
        raise ParseError, message
      end

      private

      attr_reader :file, :path

      def open_file
        if path == STDIN_PLACEHOLDER
          env.input_stream
        else
          ::File.open(path)
        end
      end

      def next_line
        file.readline.chomp
      end
    end
  end
end
