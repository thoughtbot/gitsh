require 'gitsh/arguments/pattern_value'

module Gitsh
  module Arguments
    class SingleCharacterGlob
      def value(_env)
        [PatternValue.new(/./)]
      end

      def ==(other)
        other.is_a?(self.class)
      end
    end
  end
end
