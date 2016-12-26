require 'rltk/lexer'
require 'gitsh/lexer/character_class'

module Gitsh
  class Lexer < RLTK::Lexer
    UNQUOTED_STRING_ESCAPABLES = CharacterClass.new([
      ' ', "\t", "\r", "\n", "\f",  # Whitespace
      "'", '"',                     # Quoted string delimiter
      '&', '|', ';',                # Command separator
      '#',                          # Comment prefix
      '\\',                         # Escape character
      '$',                          # Variable or sub-shell prefix
    ]).freeze

    SOFT_STRING_ESCAPABLES = CharacterClass.new([
      '\\',                         # Escape character
      '$',                          # Variable or sub-shell prefix
      '"',                          # String terminator
    ]).freeze

    HARD_STRING_ESCAPABLES = CharacterClass.new([
      '\\',                         # Escape character
      "'",                          # String terminator
    ]).freeze

    rule(/\s*;\s*/) { :SEMICOLON }
    rule(/\s*&&\s*/) { :AND }
    rule(/\s*\|\|\s*/) { :OR }

    rule(/\s+/) { :SPACE }

    rule(/#{UNQUOTED_STRING_ESCAPABLES.to_negative_regexp}+/) { |t| [:WORD, t] }
    rule(/\\#{UNQUOTED_STRING_ESCAPABLES.to_regexp}/) { |t| [:WORD, t[1]] }
    rule(/\\/) { |t| [:WORD, t] }

    rule(/#/) { push_state :comment }
    rule(/.*/, :comment) {}
    rule(/$/, :comment) { pop_state }

    rule(/''/) { [:WORD, ''] }
    rule(/'/) { push_state :hard_string }
    rule(/#{HARD_STRING_ESCAPABLES.to_negative_regexp}+/, :hard_string) do |t|
      [:WORD, t]
    end
    rule(/\\#{HARD_STRING_ESCAPABLES.to_regexp}/, :hard_string) do |t|
      [:WORD, t[1]]
    end
    rule(/\\/, :hard_string) { [:WORD, '\\'] }
    rule(/'/, :hard_string) { pop_state }

    rule(/""/) { [:WORD, ''] }
    rule(/"/) { push_state :soft_string }
    rule(/#{SOFT_STRING_ESCAPABLES.to_negative_regexp}+/, :soft_string) do |t|
      [:WORD, t]
    end
    rule(/\\#{SOFT_STRING_ESCAPABLES.to_regexp}/, :soft_string) do |t|
      [:WORD, t[1]]
    end
    rule(/\\/, :soft_string) { [:WORD, '\\'] }
    rule(/"/, :soft_string) { pop_state }

    [:default, :soft_string].each do |state|
      rule(/\$[a-z_][a-z0-9_.-]*/i, state) { |t| [:VAR, t[1..-1]] }
      rule(/\$\{[a-z_][a-z0-9_.-]*\}/i, state) { |t| [:VAR, t[2..-2]] }
    end

    [:default, :soft_string].each do |state|
      rule(/\$\(/, state) do
        @subshell_parens = 1
        push_state :subshell
        [:SUBSHELL_START]
      end
    end
    rule(/[^()]+/, :subshell) { |t| [:SUBSHELL, t] }
    rule(/\(/, :subshell) do
      @subshell_parens += 1
      [:SUBSHELL, '(']
    end
    rule(/\)/, :subshell) do
      @subshell_parens -= 1
      if @subshell_parens.zero?
        pop_state
        [:SUBSHELL_END]
      else
        [:SUBSHELL, ')']
      end
    end

    def self.lex(string, file_name = nil, env = RLTK::Lexer::Environment.new(@start_state))
      tokens = super

      case env.state
      when :hard_string
        tokens.insert(-2, RLTK::Token.new(:MISSING, '\''))
      when :soft_string
        tokens.insert(-2, RLTK::Token.new(:MISSING, '"'))
      when :subshell
        tokens.insert(-2, RLTK::Token.new(:MISSING, ')'))
      end

      tokens
    end
  end
end
