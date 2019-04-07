module Gitsh
  module Arguments
    class StringValue
      def initialize(value)
        @value = value
      end

      def expand
        value
      end

      def +(other)
        case other
        when StringValue
          StringValue.new(value + other.value)
        else
          raise ArgumentError,
            "Cannot append a #{other.class.name} to a #{self.class.name}"
        end
      end

      def ==(other)
        other.is_a?(self.class) && value == other.value
      end

      protected

      attr_reader :value
    end
  end
end
