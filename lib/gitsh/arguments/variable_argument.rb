module Gitsh
  module Arguments
    class VariableArgument
      def initialize(variable_name)
        @variable_name = variable_name
      end

      def value(env)
        [env.fetch(variable_name)]
      end

      def ==(other)
        other.is_a?(self.class) && variable_name == other.variable_name
      end

      protected

      attr_reader :variable_name
    end
  end
end
