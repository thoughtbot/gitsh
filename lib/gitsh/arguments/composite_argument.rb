module Gitsh
  module Arguments
    class CompositeArgument
      def initialize(parts)
        @parts = parts
      end

      def value(env)
        parts.
          map { |part| part.value(env) }.
          inject { |first, second| first.product(second) }.
          map { |values| values.join('') }
      end

      def ==(other)
        other.is_a?(self.class) && parts == other.parts
      end

      protected

      attr_reader :parts
    end
  end
end
