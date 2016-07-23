require 'parslet'
require 'gitsh/transformer'

module Gitsh
  class Parser < Parslet::Parser
    def initialize(options={})
      super()
      @env = options.fetch(:env)
      @transformer_factory = options.fetch(:transformer_factory, Transformer)
    end

    def parse_and_transform(command)
      transformer.apply(parse(command), env: env)
    end

    root(:program)

    rule(:program) do
      comment.as(:comment) | multi_command | blank_line
    end

    rule(:comment) do
      match('#') >> any.repeat(0)
    end

    rule(:multi_command) do
      (
        or_operation.as(:left) >>
        semicolon_operator >>
        (multi_command | blank).as(:right)
      ).as(:multi) | or_operation
    end

    rule(:blank) do
      match('\s').repeat(0).as(:blank)
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
      space.maybe >> command_identifier >> argument_list.maybe >> space.maybe >>
        comment.maybe
    end

    rule(:argument_list) do
      (space >> argument).repeat(1).as(:args)
    end

    rule(:argument) do
      (empty_string | soft_string | hard_string | unquoted_string).repeat(1).as(:arg)
    end

    rule(:unquoted_string) do
      (
        unquoted_string_escaped_literal |
        variable |
        subshell |
        match(%q([^\s'"&|;#])).as(:literal)
      ).repeat(1)
    end

    rule(:unquoted_string_escaped_literal) do
      str('\\') >> match(%q([ '"&|;#$\\\])).as(:literal)
    end

    rule(:empty_string) do
      (str('""') | str("''")).as(:empty_string)
    end

    rule(:soft_string) do
      str('"') >> (
        soft_string_escaped_literal |
        variable |
        subshell |
        (str('"').absent? >> any).as(:literal)
      ).repeat(0) >> str('"')
    end

    rule(:soft_string_escaped_literal) do
      str('\\') >> match('[$"\\\]').as(:literal)
    end

    rule(:hard_string) do
      str("'") >> (
        hard_string_escaped_literal |
        (str("'").absent? >> any).as(:literal)
      ).repeat(0) >> str("'")
    end

    rule(:hard_string_escaped_literal) do
      str('\\') >> match(%q(['\\\])).as(:literal)
    end

    rule(:command_identifier) do
      (str(':') >> identifier.as(:internal_cmd)) |
      (str('!') >> identifier.as(:shell_cmd)) |
      git_command_identifier
    end

    rule(:git_command_identifier) do
      if autocorrect_enabled?
        (str('git') >> space).maybe >> identifier.as(:git_cmd)
      else
        identifier.as(:git_cmd)
      end
    end

    rule(:variable) do
      str('$') >> (
        str('{') >> variable_name.as(:var) >> str('}') |
        variable_name.as(:var)
      )
    end

    rule(:variable_name) do
      match('[A-Za-z_]') >> match('[A-Za-z0-9._\-]').repeat(0)
    end

    rule(:subshell) do
      str('$(') >> (subshell_content).as(:subshell) >> str(')')
    end

    rule(:subshell_content) do
      (
        (str('(') >> subshell_content >> str(')')) |
        (str(')').absent? >> any)
      ).repeat(0)
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

    attr_reader :transformer_factory, :env

    def transformer
      @transformer ||= transformer_factory.new
    end

    def autocorrect_enabled?
      env.fetch('help.autocorrect') { '0' } != '0'
    end
  end
end
