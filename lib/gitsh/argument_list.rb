module Gitsh
  class ArgumentList
    def initialize(args)
      @args = args
    end

    def length
      args.length
    end

    def values(env)
      @args.map do |arg|
        arg.value(env)
      end
    end

    private

    attr_reader :args
  end
end
