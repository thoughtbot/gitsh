require 'spec_helper'
require 'gitsh/tab_completion/dsl/lexer'

describe Gitsh::TabCompletion::DSL::Lexer do
  describe '.lex' do
    it 'recognises space separated words' do
      expect('stash pop').to produce_tokens ['WORD(stash)', 'WORD(pop)', 'EOS']
    end

    it 'recognises variables' do
      expect('add $opt').to produce_tokens ['WORD(add)', 'VAR(opt)', 'EOS']
    end

    it 'recognises long options' do
      expect('--foo').to produce_tokens ['OPTION(--foo)', 'EOS']
    end

    it 'recognises short options' do
      expect('-S').to produce_tokens ['OPTION(-S)', 'EOS']
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

    it 'ignores comments' do
      expect('# comment').to produce_tokens ['EOS']
      expect("# comment\npush").to produce_tokens ['WORD(push)', 'EOS']
      expect("push\n\n# comment\npull").
        to produce_tokens ['WORD(push)', 'BLANK', 'WORD(pull)', 'EOS']
      expect("push\n  --force   # caution!\n  --force-with-lease").
        to produce_tokens ['WORD(push)', 'INDENT', 'OPTION(--force)', 'INDENT', 'OPTION(--force-with-lease)', 'EOS']
    end
  end
end
