module Gitsh
  module Arguments
    class BraceExpansion
      def initialize(options)
        @options = options
      end

      def value(env)
        options.flat_map { |option| option.value(env) }
      end

      def ==(other)
        other.is_a?(self.class) && options == other.options
      end

      protected

      attr_reader :options
    end
  end
end
