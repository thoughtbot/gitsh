module Gitsh
  module Arguments
    class StringArgument
      def initialize(value)
        @value = value
      end

      def value(env)
        @value
      end
    end
  end
end
