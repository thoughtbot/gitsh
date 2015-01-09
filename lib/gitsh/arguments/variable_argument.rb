module Gitsh
  module Arguments
    class VariableArgument
      def initialize(variable_name)
        @variable_name = variable_name
      end

      def value(env)
        env.fetch(@variable_name)
      end
    end
  end
end
