require 'spec_helper'
require 'gitsh/tab_completion/dsl/lexer'

RSpec::Matchers.define(:produce_tokens) do |expected|
  match do |actual|
    @expected = expected.join("\n")
    @actual = Gitsh::TabCompletion::DSL::Lexer.
      lex(actual).map(&:to_s).join("\n")
    values_match? @expected, @actual
  end

  diffable
end

describe Gitsh::TabCompletion::DSL::Lexer do
  describe '.lex' do
    it 'recognises space separated words' do
      expect('stash pop').to produce_tokens ['WORD(stash)', 'WORD(pop)', 'EOS']
    end

    it 'recognises variables' do
      expect('add $opt').to produce_tokens ['WORD(add)', 'VAR(opt)', 'EOS']
    end

    it 'recognises options' do
      expect('--foo').to produce_tokens ['OPTION(--foo)', 'EOS']
    end

    it 'recognises the asterisk operator' do
      expect('add* $opt*').
        to produce_tokens ['WORD(add)', 'STAR', 'VAR(opt)', 'STAR', 'EOS']
    end

    it 'recognises the plus operator' do
      expect('add+ $opt+').
        to produce_tokens ['WORD(add)', 'PLUS', 'VAR(opt)', 'PLUS', 'EOS']
    end

    it 'recognises the question mark operator' do
      expect('add? $opt?').
        to produce_tokens ['WORD(add)', 'MAYBE', 'VAR(opt)', 'MAYBE', 'EOS']
    end

    it 'recognises the pipe operator' do
      expect('stash pop|drop').to produce_tokens [
        'WORD(stash)', 'WORD(pop)', 'OR', 'WORD(drop)', 'EOS',
      ]
    end

    it 'recognises parentheses' do
      expect('(add|commit)').to produce_tokens [
        'LEFT_PAREN', 'WORD(add)', 'OR', 'WORD(commit)', 'RIGHT_PAREN', 'EOS',
      ]
    end

    it 'recognises indented lines' do
      expect("push\n  --force \n  --all").to produce_tokens [
        'WORD(push)', 'INDENT', 'OPTION(--force)',
        'INDENT', 'OPTION(--all)', 'EOS',
      ]
    end

    it 'recognises blank lines' do
      expect("push\n\npull").
        to produce_tokens ['WORD(push)', 'BLANK', 'WORD(pull)', 'EOS']
      expect("push  \n  \npull").
        to produce_tokens ['WORD(push)', 'BLANK', 'WORD(pull)', 'EOS']
    end
  end
end
