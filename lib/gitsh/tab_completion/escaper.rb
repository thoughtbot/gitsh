require 'gitsh/lexer'
require 'gitsh/registry'

module Gitsh
  module TabCompletion
    class Escaper
      extend Registry::Client
      use_registry_for :line_editor

      ESCAPABLES = {
        nil => Gitsh::Lexer::UNQUOTED_STRING_ESCAPABLES,
        '"' => Gitsh::Lexer::SOFT_STRING_ESCAPABLES,
        "'" => Gitsh::Lexer::HARD_STRING_ESCAPABLES,
      }.freeze

      def escape(option)
        option.gsub(escapables) { |char| "\\#{char}" }
      end

      def unescape(input)
        input.gsub(/\\(#{escapables})/, '\1')
      end

      private

      def escapables
        ESCAPABLES[line_editor.completion_quote_character].to_regexp
      end
    end
  end
end
