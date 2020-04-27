require 'gitsh/registry'

module Gitsh
  module TabCompletion
    class VariableCompleter
      extend Registry::Client
      use_registry_for :env, :line_editor

      def initialize(input)
        @input = input
      end

      def call
        line_editor.completion_append_character = completion_append_character
        line_editor.completion_suppress_quote = true

        matches
      end

      private

      attr_reader :input

      def completion_append_character
        if prefix.end_with?('{')
          '}'
        else
          nil
        end
      end

      def matches
        env.available_variables.
          select { |name| name.to_s.start_with?(partial_name) }.
          map { |name| "#{prefix}#{name}" }
      end

      def prefix
        parse_input.first
      end

      def partial_name
        parse_input.last
      end

      def parse_input
        @parse_input ||= (
          parts = input.rpartition(/\$\{?/)
          [parts[0...-1].join, parts.last]
        )
      end
    end
  end
end
