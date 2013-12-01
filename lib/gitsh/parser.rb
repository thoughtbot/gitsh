require 'parslet'
require 'gitsh/transformer'

module Gitsh
  class Parser < Parslet::Parser
    def initialize(options={})
      super()
      @transformer_factory = options.fetch(:transformer_factory, Transformer)
    end

    def parse_and_transform(command)
      transformer.apply(parse(command))
    end

    rule(:space) { match('\s').repeat(1) }

    rule(:identifier) { match('[a-z]') >> match('[a-z0-9-]').repeat(0) }
    rule(:command_identifier) { identifier.as(:git_cmd) }

    rule(:unquoted_string) { match('\S').as(:literal).repeat(1) }
    rule(:soft_string) { match('"') >> match('[^"]').as(:literal).repeat(0) >> match('"') }
    rule(:hard_string) { match("'") >> match("[^']").as(:literal).repeat(0) >> match("'") }

    rule(:argument) { (soft_string | hard_string | unquoted_string).as(:arg) }
    rule(:argument_list) { (space >> argument).repeat(1).as(:args) }

    rule(:command) { command_identifier >> argument_list.maybe >> space.maybe }
    root(:command)

    private

    attr_reader :transformer_factory

    def transformer
      transformer_factory.new
    end
  end
end
