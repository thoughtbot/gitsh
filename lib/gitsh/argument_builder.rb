require 'gitsh/arguments/composite_argument'
require 'gitsh/arguments/string_argument'
require 'gitsh/arguments/subshell'
require 'gitsh/arguments/variable_argument'
require 'gitsh/interpreter'

module Gitsh
  class ArgumentBuilder
    def self.build
      builder = new
      yield builder
      builder.argument
    end

    def initialize
      @arguments = []
      @literals = []
    end

    def add_literal(literal)
      literals << literal
    end

    def add_variable(variable_name)
      collect_literals
      arguments << Arguments::VariableArgument.new(variable_name)
    end

    def add_subshell(command)
      collect_literals
      arguments << Arguments::Subshell.new(command)
    end

    def argument
      collect_literals
      combined_arguments
    end

    private

    attr_accessor :literals
    attr_reader :arguments

    def collect_literals
      if literals.any?
        arguments << Arguments::StringArgument.new(literals.join(''))
        self.literals = []
      end
    end

    def combined_arguments
      if arguments.length == 1
        arguments.first
      else
        Arguments::CompositeArgument.new(arguments)
      end
    end
  end
end
