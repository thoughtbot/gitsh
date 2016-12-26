require 'gitsh/lexer'

module Gitsh
  class CompletionEscaper
    ESCAPABLES = {
      nil => Gitsh::Lexer::UNQUOTED_STRING_ESCAPABLES,
      '"' => Gitsh::Lexer::SOFT_STRING_ESCAPABLES,
      "'" => Gitsh::Lexer::HARD_STRING_ESCAPABLES,
    }.freeze

    def initialize(completer, options)
      @completer = completer
      @line_editor = options[:line_editor]
    end

    def call(input)
      completer.call(unescape(input)).map { |option| escape(option) }
    end

    private

    attr_reader :completer, :line_editor

    def escape(option)
      option.gsub(escapables) { |char| "\\#{char}" }
    end

    def unescape(input)
      input.gsub(/\\(#{escapables})/, '\1')
    end

    def escapables
      ESCAPABLES[line_editor.completion_quote_character].to_regexp
    end
  end
end
