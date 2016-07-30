require 'gitsh/parser'

module Gitsh
  class CompletionEscaper
    ESCAPABLES = {
      nil => Gitsh::Parser::UNQUOTED_STRING_ESCAPABLES,
      '"' => Gitsh::Parser::SOFT_STRING_ESCAPABLES,
      "'" => Gitsh::Parser::HARD_STRING_ESCAPABLES,
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
      option.gsub(/([#{escapables}])/) { |char| "\\#{char}" }
    end

    def unescape(input)
      input.gsub(/\\([#{escapables}])/, '\1')
    end

    def escapables
      @_escapables ||= ESCAPABLES[line_editor.completion_quote_character]
    end
  end
end
