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

    rule(:space) { match('\s').repeat(1) }

    rule(:identifier) { match('[a-z]') >> match('[a-z0-9-]').repeat(0) }
    rule(:command_identifier) { (match(':') >> identifier.as(:internal_cmd)) | identifier.as(:git_cmd) }
    rule(:variable) { match('\$') >> (match('{') >> identifier.as(:var) >> match('}') | identifier.as(:var)) }

    rule(:unquoted_string) { (variable | match(%q([^\s'"])).as(:literal)).repeat(1) }
    rule(:soft_string) { match('"') >> (variable | match('[^"]').as(:literal)).repeat(0) >> match('"') }
    rule(:hard_string) { match("'") >> match("[^']").as(:literal).repeat(0) >> match("'") }

    rule(:argument) { (soft_string | hard_string | unquoted_string).repeat(1).as(:arg) }
    rule(:argument_list) { (space >> argument).repeat(1).as(:args) }

    rule(:command) { command_identifier >> argument_list.maybe >> space.maybe }
    root(:command)

    private

    attr_reader :transformer_factory

    def transformer
      @transformer ||= transformer_factory.new
    end
  end
end
