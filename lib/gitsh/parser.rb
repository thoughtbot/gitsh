require 'parslet'
require 'gitsh/transformer'

module Gitsh
  class Parser < Parslet::Parser
    def initialize(options={})
      super()
      @transformer_factory = options.fetch(:transformer_factory, Transformer)
    end

    def parse_and_transform(command, env)
      transformer.apply(parse(command), env: env)
    end

    root(:program)

    rule(:program) do
      comment | multi_command | blank_line
    end

    rule(:comment) do
      (match('#') >> any.repeat(0)).as(:comment)
    end

    rule(:multi_command) do
      (
        or_operation.as(:left) >>
        semicolon_operator >>
        multi_command.as(:right)
      ).as(:multi) | or_operation
    end

    rule(:blank_line) do
      (match('^') >> match('\s').repeat(0) >> match('$')).as(:blank)
    end

    rule(:or_operation) do
      (
        and_operation.as(:left) >>
        or_operator >>
        or_operation.as(:right)
      ).as(:or) | and_operation
    end

    rule(:and_operation) do
      (
        command.as(:left) >>
        and_operator >>
        and_operation.as(:right)
      ).as(:and) | command
    end

    rule(:command) do
      space.maybe >> command_identifier >> argument_list.maybe >> space.maybe
    end

    rule(:argument_list) do
      (space >> argument).repeat(1).as(:args)
    end

    rule(:argument) do
      (empty_string | soft_string | hard_string | unquoted_string).repeat(1).as(:arg)
    end

    rule(:unquoted_string) do
      (variable | match(%q([^\s'"&|;])).as(:literal)).repeat(1)
    end

    rule(:empty_string) do
      (str('""') | str("''")).as(:empty_string)
    end

    rule(:soft_string) do
      str('"') >> (
        (str('\\') >> match('[$"\\\]').as(:literal)) |
        variable |
        (str('"').absent? >> any).as(:literal)
      ).repeat(0) >> str('"')
    end

    rule(:hard_string) do
      str("'") >> (str("'").absent? >> any).as(:literal).repeat(0) >> str("'")
    end

    rule(:command_identifier) do
      (str(':') >> identifier.as(:internal_cmd)) |
      (str('!') >> identifier.as(:shell_cmd)) |
      identifier.as(:git_cmd)
    end

    rule(:variable) do
      str('$') >> (
        str('{') >> variable_name.as(:var) >> str('}') |
        variable_name.as(:var)
      )
    end

    rule(:variable_name) do
      match('[A-Za-z]') >> match('[A-Za-z0-9._\-]').repeat(0)
    end

    rule(:identifier) do
      match('[A-Za-z./]') >> match('[A-Za-z0-9.\-/_]').repeat(0)
    end

    rule(:space) do
      match('\s').repeat(1)
    end

    rule(:and_operator) do
      str('&&') >> space.maybe
    end

    rule(:or_operator)  do
      str('||')  >> space.maybe
    end

    rule(:semicolon_operator)  do
      str(';')  >> space.maybe
    end

    private

    attr_reader :transformer_factory

    def transformer
      @transformer ||= transformer_factory.new
    end
  end
end
