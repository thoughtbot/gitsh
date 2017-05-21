require 'gitsh/pipeline_environment'

module Gitsh
  module Commands
    class Pipeline
      def initialize(left, right)
        @left = left
        @right = right
      end

      def execute(env)
        left_env, right_env = PipelineEnvironment.build_pair(env)
        threads = [start_left_thread(left_env), start_right_thread(right_env)]
        wait_for_threads(threads)
        threads.map(&:value).all?
      end

      private

      attr_reader :left, :right, :threads

      def start_left_thread(env)
        Thread.new { execute_left(env) }
      end

      def start_right_thread(env)
        Thread.new { execute_right(env) }
      end

      def execute_left(left_env)
        left.execute(left_env)
      ensure
        left_env.output_stream.close
      end

      def execute_right(right_env)
        right.execute(right_env)
      ensure
        right_env.input_stream.close
      end

      def wait_for_threads(threads)
        threads.map(&:join)
      rescue Interrupt
        threads.each { |thread| thread.raise(Interrupt) }
        retry
      end
    end
  end
end
