require 'gitsh/parser'

module Gitsh
  class CompletionEscaper
    UNQUOTED_STRING_ESCAPABLES = Gitsh::Parser::UNQUOTED_STRING_ESCAPABLES
    QUOTED_STRING_ESCAPABLES = {
      '"' => Gitsh::Parser::SOFT_STRING_ESCAPABLES,
      "'" => Gitsh::Parser::HARD_STRING_ESCAPABLES,
    }.freeze

    def initialize(completer, options)
      @completer = completer
      @line_editor = options[:line_editor]
    end

    def call(input)
      OptionEscaper.new(
        completer,
        input,
        line_editor,
      ).escaped_options
    end

    private

    attr_reader :completer, :line_editor

    class OptionEscaper
      def initialize(completer, input, line_editor)
        @completer = completer
        @input = input
        @line_editor = line_editor
      end

      def escaped_options
        unescaped_options.map { |option| escape(option) }
      end

      private

      attr_reader :completer, :input, :line_editor

      def unescaped_options
        completer.call(unescape(input))
      end

      def escape(option)
        escaped = option.gsub(/([#{escapables}])(?!$)/) { |char| "\\#{char}" }

        if completing_quoted_argument?
          escaped.strip
        else
          escaped
        end
      end

      def unescape(input)
        input.gsub(/\\([#{escapables}])/, '\1')
      end

      def escapables
        if completing_quoted_argument?
          QUOTED_STRING_ESCAPABLES[line_editor.completion_quote_character]
        else
          UNQUOTED_STRING_ESCAPABLES
        end
      end

      def completing_quoted_argument?
        !line_editor.completion_quote_character.nil?
      end
    end
  end
end
