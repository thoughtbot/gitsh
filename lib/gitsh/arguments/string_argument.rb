require 'gitsh/arguments/string_value'

module Gitsh
  module Arguments
    class StringArgument
      def initialize(value)
        @raw_value = value
      end

      def value(_env)
        [StringValue.new(raw_value)]
      end

      def ==(other)
        other.is_a?(self.class) && raw_value == other.raw_value
      end

      protected

      attr_reader :raw_value
    end
  end
end
