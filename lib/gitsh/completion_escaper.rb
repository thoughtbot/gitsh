module Gitsh
  class CompletionEscaper
    QUOTABLE_CHARACTERS = [' ']

    def initialize(completer, options)
      @completer = completer
      @line_editor = options[:line_editor]
    end

    def call(input)
      OptionEscaper.new(
        completer.call(input),
        input,
        line_editor.line_buffer,
      ).escaped_options
    end

    private

    attr_reader :completer, :line_editor

    class OptionEscaper
      def initialize(unescaped_options, input, full_input)
        @unescaped_options = unescaped_options
        @input = input
        @full_input = full_input
      end

      def escaped_options
        unescaped_options.map { |option| escape(option) }
      end

      private

      attr_reader :unescaped_options, :input, :full_input

      def escape(option)
        if completing_quoted_argument?
          option.strip
        else
          quotable_characters = QUOTABLE_CHARACTERS.join
          option.gsub(/([#{quotable_characters}])(?!$)/) { |char| "\\#{char}" }
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
