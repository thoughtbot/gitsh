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
      def execute(env, completer)
        left.execute(env, completer)
        right.execute(env, completer)
      end
    end

    class Or < Branch
      def execute(env, completer)
        left.execute(env, completer) || right.execute(env, completer)
      end
    end

    class And < Branch
      def execute(env, completer)
        left.execute(env, completer) && right.execute(env, completer)
      end
    end
  end
end
