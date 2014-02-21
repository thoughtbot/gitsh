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

    root(:command)

    rule(:command) do
      space.maybe >> command_identifier >> argument_list.maybe >> space.maybe
    end

    rule(:argument_list) do
      (space >> argument).repeat(1).as(:args)
    end

    rule(:argument) do
      (soft_string | hard_string | unquoted_string).repeat(1).as(:arg)
    end

    rule(:unquoted_string) do
      (variable | match(%q([^\s'"])).as(:literal)).repeat(1)
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
        str('{') >> identifier.as(:var) >> str('}') |
        identifier.as(:var)
      )
    end

    rule(:identifier) do
      match('[a-z]') >> match('[a-z0-9.-]').repeat(0)
    end

    rule(:space) do
      match('\s').repeat(1)
    end

    private

    attr_reader :transformer_factory

    def transformer
      @transformer ||= transformer_factory.new
    end
  end
end
