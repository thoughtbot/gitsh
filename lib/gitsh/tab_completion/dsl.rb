require 'gitsh/tab_completion/dsl/lexer'
require 'gitsh/tab_completion/dsl/parser'

module Gitsh
  module TabCompletion
    module DSL
      def self.load(path, start_state, env)
        source = File.read(path)
        tokens = Lexer.lex(source)
        factory = Parser.parse(tokens, gitsh_env: env)
        factory.build(start_state)
      end
    end
  end
end
