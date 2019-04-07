module Gitsh
  module Arguments
    class StringValue
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def expand
        [value]
      end

      def +(other)
        case other
        when StringValue
          StringValue.new(value + other.value)
        when PatternValue
          PatternValue.new(Regexp.new(value + other.pattern.source))
        else
          raise ArgumentError,
            "Cannot append a #{other.class.name} to a #{self.class.name}"
        end
      end

      def ==(other)
        other.is_a?(self.class) && value == other.value
      end
    end
  end
end
