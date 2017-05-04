require 'gitsh/tab_completion/dsl/lexer'
require 'gitsh/tab_completion/dsl/parser'

module Gitsh
  module TabCompletion
    module DSL
      def self.load(path, start_state)
        source = File.read(path)
        tokens = Lexer.lex(source)
        factory = Parser.parse(tokens)
        factory.build(start_state)
      end
    end
  end
end
