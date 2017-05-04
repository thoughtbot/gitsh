require 'rltk/lexer'

module Gitsh
  module TabCompletion
    module DSL
      class Lexer < RLTK::Lexer
        rule(/\$[a-z_]+/) { |t| [:VAR, t[1..-1]] }
        rule(/--[^\s*+?|()]+/) { |t| [:OPTION, t] }
        rule(/[^\s*+?|()]+/) { |t| [:WORD, t] }
        rule(/\*/) { :STAR }
        rule(/\+/) { :PLUS }
        rule(/\?/) { :MAYBE }
        rule(/\|/) { :OR }
        rule(/\(/) { :LEFT_PAREN }
        rule(/\)/) { :RIGHT_PAREN }
        rule(/\s*\n\s*\n/) { :BLANK }
        rule(/\s*\n\s+/) { :INDENT }
        rule(/\s+/) { }
      end
    end
  end
end
