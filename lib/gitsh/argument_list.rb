module Gitsh
  class ArgumentList
    def initialize(args)
      @args = args
    end

    def length
      args.length
    end

    def values(env, completer)
      arg_graph_traversal = completer.session

      @args.
        flat_map { |arg| arg.value(env) }.
        flat_map do |value|
          final_values = value.expand { arg_graph_traversal.completions }
          arg_graph_traversal.step_through(final_values)
          final_values
        end
    end

    private

    attr_reader :args
  end
end
