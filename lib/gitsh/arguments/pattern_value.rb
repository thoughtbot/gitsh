module Gitsh
  module Arguments
    class PatternValue
      attr_reader :pattern, :source

      def initialize(pattern, source)
        @pattern = pattern
        @source = source
      end

      def expand
        options = yield
        matches = options.grep(regexp)
        if matches.any?
          matches
        else
          [source]
        end
      end

      def +(other)
        case other
        when PatternValue
          PatternValue.new(
            pattern + other.pattern,
            source + other.source,
          )
        when StringValue
          PatternValue.new(
            pattern + Regexp.escape(other.value),
            source + other.value,
          )
        else
          raise ArgumentError,
            "Cannot append a #{other.class.name} to a #{self.class.name}"
        end
      end

      def ==(other)
        other.is_a?(self.class) && pattern == other.pattern
      end

      private

      def regexp
        Regexp.new("^#{pattern}$")
      end
    end
  end
end
