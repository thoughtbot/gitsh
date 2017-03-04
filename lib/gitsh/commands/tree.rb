module Gitsh::Commands
  module Tree
    class Branch
      def initialize(left, right)
        @left = left
        @right = right
      end

      private

      attr_reader :left, :right
    end

    class Multi < Branch
      def execute(env)
        left.execute(env)
        right.execute(env)
      end
    end

    class Or < Branch
      def execute(env)
        left.execute(env) || right.execute(env)
      end
    end

    class And < Branch
      def execute(env)
        left.execute(env) && right.execute(env)
      end
    end
  end
end
