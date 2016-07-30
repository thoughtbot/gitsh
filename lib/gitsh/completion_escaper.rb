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
        line_editor.line_buffer,
      ).escaped_options
    end

    private

    attr_reader :completer, :line_editor

    class OptionEscaper
      def initialize(completer, input, full_input)
        @completer = completer
        @input = input
        @full_input = full_input
      end

      def escaped_options
        unescaped_options.map { |option| escape(option) }
      end

      private

      attr_reader :completer, :input, :full_input

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
          QUOTED_STRING_ESCAPABLES[quote_char]
        else
          UNQUOTED_STRING_ESCAPABLES
        end
      end

      def completing_quoted_argument?
        @_quoted ||= (quote_char == '"' || quote_char == "'")
      end

      def quote_char
        input_before_current_argument[-1]
      end

      def input_before_current_argument
        full_input[0...-input.length]
      end
    end
  end
end
