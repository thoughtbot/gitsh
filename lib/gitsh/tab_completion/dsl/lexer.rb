require 'rltk/lexer'

module Gitsh
  module TabCompletion
    module DSL
      class Lexer < RLTK::Lexer
        WORD_CHARACTERS = /[^\s*+?|()#\$]/

        rule(/\$opt/) { :OPT_VAR }
        rule(/\$[a-z_]+/) { |t| [:VAR, t[1..-1]] }

        rule(/[a-z_]+::/) { |t| [:MODIFIER, t[0..-3]] }

        rule(/-[A-Za-z0-9]/) { |t| [:OPTION, t] }
        rule(/--#{WORD_CHARACTERS}+/) { |t| [:OPTION, t] }

        rule(/#{WORD_CHARACTERS}+/) { |t| [:WORD, t] }

        rule(/\*/) { :STAR }
        rule(/\+/) { :PLUS }
        rule(/\?/) { :MAYBE }
        rule(/\|/) { :OR }
        rule(/\(/) { :LEFT_PAREN }
        rule(/\)/) { :RIGHT_PAREN }

        rule(/\s*\n\s*\n/) { :BLANK }
        rule(/\s*\n\s+/) { :INDENT }
        rule(/\s+/) {}

        rule(/#/) { push_state :comment }
        rule(/[^\n]+/, :comment) {}
        rule(/(?=\n)/, :comment) { pop_state }
      end
    end
  end
end
