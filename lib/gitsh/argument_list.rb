module Gitsh
  class ArgumentList
    def initialize(args)
      @args = args
    end

    def length
      args.length
    end

    def values(env)
      @args.flat_map { |arg| arg.value(env) }
    end

    private

    attr_reader :args
  end
end
