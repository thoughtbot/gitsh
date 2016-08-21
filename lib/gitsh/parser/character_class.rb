require 'parslet'

module Gitsh
  class Parser < Parslet::Parser
    class CharacterClass
      attr_reader :characters

      def initialize(characters)
        @characters = characters
      end

      def +(other)
        self.class.new(characters + other.characters)
      end

      def parser_atom
        Parslet.match(to_regexp)
      end

      def to_regexp
        Regexp.new("[#{Regexp.escape(characters.join)}]")
      end
    end
  end
end
