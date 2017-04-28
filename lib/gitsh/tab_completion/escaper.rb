require 'gitsh/lexer'

module Gitsh
  module TabCompletion
    class Escaper
      ESCAPABLES = {
        nil => Gitsh::Lexer::UNQUOTED_STRING_ESCAPABLES,
        '"' => Gitsh::Lexer::SOFT_STRING_ESCAPABLES,
        "'" => Gitsh::Lexer::HARD_STRING_ESCAPABLES,
      }.freeze

      def initialize(line_editor)
        @line_editor = line_editor
      end

      def escape(option)
        option.gsub(escapables) { |char| "\\#{char}" }
      end

      def unescape(input)
        input.gsub(/\\(#{escapables})/, '\1')
      end

      private

      attr_reader :line_editor

      def escapables
        ESCAPABLES[line_editor.completion_quote_character].to_regexp
      end
    end
  end
end
