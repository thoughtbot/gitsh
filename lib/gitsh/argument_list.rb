module Gitsh
  class ArgumentList
    def initialize(args)
      @args = args
    end

    def length
      args.length
    end

    def values(env)
      #FIXME: Don't rebuild this
      require 'gitsh/tab_completion/automaton_factory'
      completer = TabCompletion::AutomatonFactory.build(env).walker

      @args.
        flat_map { |arg| arg.value(env) }.
        flat_map do |value|
          final_values = value.expand { p completer.completions }
          completer.step_through(final_values)
          final_values
        end
    end

    private

    attr_reader :args
  end
end
