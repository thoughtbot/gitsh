module Gitsh
  class CompletionEscaper
    UNQUOTED_STRING_ESCAPE_CHARACTERS = [
      ' ', '"', '\'', '\\', '$', '&', '|', ';', '#',
    ].freeze
    QUOTED_STRING_ESCAPE_CHARACTERS = {
      '"' => ['"', '\\', '$'],
      "'" => ["'", '\\'],
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
        if completing_quoted_argument?
          quote_char = input_before_current_argument[-1]
          escape_chars = QUOTED_STRING_ESCAPE_CHARACTERS[quote_char]
          escape_chars(option, escape_chars).strip
        else
          escape_chars(option, UNQUOTED_STRING_ESCAPE_CHARACTERS)
        end
      end

      def escape_chars(text, chars)
        quotable_characters = Regexp.escape(chars.join)
        text.gsub(/([#{quotable_characters}])(?!$)/) { |char| "\\#{char}" }
      end

      def unescape(input)
        found_quote = false
        input.chars.inject('') do |unescaped, char|
          if !found_quote && char == '\\'
            found_quote = true
            unescaped
          else
            found_quote = false
            unescaped + char
          end
        end
      end

      def completing_quoted_argument?
        @_quoted ||= input_before_current_argument.end_with?('"', "'")
      end

      def input_before_current_argument
        full_input[0...-input.length]
      end
    end
  end
end
