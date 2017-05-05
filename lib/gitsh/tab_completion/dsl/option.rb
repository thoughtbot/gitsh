module Gitsh
  module TabCompletion
    module DSL
      class Option
        attr_reader :name, :argument_factory

        def initialize(name, argument_factory = nil)
          @name = name
          @argument_factory = argument_factory
        end

        def has_argument?
          !argument_factory.nil?
        end
      end
    end
  end
end
