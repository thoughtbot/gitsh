module Gitsh
  module Arguments
    class CompositeArgument
      def initialize(parts)
        @parts = parts
      end

      def value(env)
        @parts.map { |part| part.value(env) }.join('')
      end
    end
  end
end
