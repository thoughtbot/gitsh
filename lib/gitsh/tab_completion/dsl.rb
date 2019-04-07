require 'gitsh/tab_completion/dsl/lexer'
require 'gitsh/tab_completion/dsl/parser'

module Gitsh
  module TabCompletion
    module DSL
      def self.load(path, start_state)
        source = File.read(path)
        tokens = Lexer.lex(source, path)
        factory = Parser.parse(tokens, gitsh_env: Registry.env)
        factory.build(start_state)
      rescue Errno::ENOENT
      end
    end
  end
end
