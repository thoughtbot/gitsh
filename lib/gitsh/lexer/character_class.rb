require 'rltk'

module Gitsh
  class Lexer < RLTK::Lexer
    class CharacterClass
      attr_reader :characters

      def initialize(characters)
        @characters = characters
      end

      def +(other)
        self.class.new(characters + other.characters)
      end

      def to_regexp
        Regexp.new("[#{Regexp.escape(characters.join)}]")
      end

      def to_negative_regexp
        Regexp.new("[^#{Regexp.escape(characters.join)}]")
      end
    end
  end
end
