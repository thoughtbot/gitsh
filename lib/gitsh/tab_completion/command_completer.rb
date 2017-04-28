module Gitsh
  module TabCompletion
    class CommandCompleter
      def initialize(line_editor, prior_words, input, automaton, escaper)
        @line_editor = line_editor
        @prior_words = prior_words
        @input = input
        @automaton = automaton
        @escaper = escaper
      end

      def call
        line_editor.completion_append_character = completion_append_character
        line_editor.completion_suppress_quote = incomplete_path?

        matches
      end

      private

      attr_reader :line_editor, :prior_words, :input, :automaton, :escaper

      def completion_append_character
        if incomplete_path?
          nil
        else
          ' '
        end
      end

      def incomplete_path?
        matches.size == 1 && matches.first.end_with?('/')
      end

      def matches
        @matches ||= automaton.
          completions(prior_words, escaper.unescape(input)).
          map { |match| escaper.escape(match) }
      end
    end
  end
end
