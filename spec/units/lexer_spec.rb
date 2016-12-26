require 'spec_helper'
require 'gitsh/lexer'

RSpec::Matchers.define(:produce_tokens) do |expected|
  match do |actual|
    @expected = expected.join("\n")
    @actual = Gitsh::Lexer.lex(actual).map(&:to_s).join("\n")
    values_match? @expected, @actual
  end

  diffable
end

describe Gitsh::Lexer do
  describe '.lex' do
    it 'recognises space separated words' do
      expect('foo bar').
        to produce_tokens ['WORD(foo)', 'SPACE', 'WORD(bar)', 'EOS']
      expect('!./bin/setup --help').
        to produce_tokens ['WORD(!./bin/setup)', 'SPACE', 'WORD(--help)', 'EOS']
    end

    it 'recognises the semicolon operator' do
      expect('foo;').
        to produce_tokens ['WORD(foo)', 'SEMICOLON', 'EOS']
      expect('foo; bar').
        to produce_tokens ['WORD(foo)', 'SEMICOLON', 'WORD(bar)', 'EOS']
      expect('foo  ; bar').
        to produce_tokens ['WORD(foo)', 'SEMICOLON', 'WORD(bar)', 'EOS']
    end

    it 'recognises the && operator' do
      expect('foo && bar').
        to produce_tokens ['WORD(foo)', 'AND', 'WORD(bar)', 'EOS']
    end

    it 'recognises the || operator' do
      expect('foo || bar').
        to produce_tokens ['WORD(foo)', 'OR', 'WORD(bar)', 'EOS']
    end

    [' ', "\t", "\r", "\n", "\f", '\'', '"', '\\', '$', '#', ';', '&', '|'].each do |char|
      it "recognises unquoted words containing an escaped #{char.inspect}" do
        expect("foo\\#{char}bar").
          to produce_tokens ['WORD(foo)', "WORD(#{char})", 'WORD(bar)', 'EOS']
      end
    end

    it 'does not treat all \ characters in unquoted words as escapes' do
      expect('\\a').to produce_tokens ['WORD(\\)', 'WORD(a)', 'EOS']
    end

    it 'recognises variables' do
      expect('$foo').to produce_tokens ['VAR(foo)', 'EOS']
      expect('${foo}').to produce_tokens ['VAR(foo)', 'EOS']
      expect('pre$foo').to produce_tokens ['WORD(pre)', 'VAR(foo)', 'EOS']
      expect('pre${foo}post').
        to produce_tokens ['WORD(pre)', 'VAR(foo)', 'WORD(post)', 'EOS']
      expect('pre$foo/post').
        to produce_tokens ['WORD(pre)', 'VAR(foo)', 'WORD(/post)', 'EOS']
      expect('$f_o-o.bar').to produce_tokens ['VAR(f_o-o.bar)', 'EOS']
      expect('$_bar').to produce_tokens ['VAR(_bar)', 'EOS']
    end

    it 'recognises single-quoted strings as single words' do
      expect('\'foo bar\'').
        to produce_tokens ['WORD(foo bar)', 'EOS']
    end

    ['\\', '\''].each do |char|
      it "recognises single-quoted strings containing an escaped #{char.inspect}" do
        expect("'foo\\#{char}bar'").
          to produce_tokens ['WORD(foo)', "WORD(#{char})", 'WORD(bar)', 'EOS']
      end
    end

    it 'does not interpret all \ characters in single-quoted arguments as escapes' do
      ['a', ' ', '"', '&', '|', ';', '#', '$'].each do |char|
        expect("'\\#{char}'").
          to produce_tokens ['WORD(\\)', "WORD(#{char})", 'EOS']
      end
    end

    it 'recognises single-quoted strings containing variable-like values' do
      expect("'hello $world'").
        to produce_tokens ['WORD(hello $world)', 'EOS']
    end

    it 'recognises double-quoted strings as single words' do
      expect('"foo bar"').
        to produce_tokens ['WORD(foo bar)', 'EOS']
    end

    ['\\', '"', '$'].each do |char|
      it "recognises double-quoted strings containing an escaped #{char.inspect}" do
        expect("\"foo\\#{char}bar\"").
          to produce_tokens ['WORD(foo)', "WORD(#{char})", 'WORD(bar)', 'EOS']
      end
    end

    it 'does not treat all \ characters in double-quoted strings as escapes' do
      ['a', ' ', '\'', '&', '|', ';', '#'].each do |char|
        expect("\"\\#{char}\"").
          to produce_tokens ['WORD(\\)', "WORD(#{char})", 'EOS']
      end
    end

    it 'does not treat single quotes in double-quoted strings as single-quoted strings' do
      expect(%q{"'$foo'"}).
        to produce_tokens ["WORD(')", "VAR(foo)", "WORD(')", "EOS"]
    end

    it 'ignores the comment prefix in quoted strings' do
      expect('\'no # comment\' "no # comment"').
        to produce_tokens ['WORD(no # comment)', 'SPACE', 'WORD(no # comment)', 'EOS']
    end

    it 'recognises variables in double-quoted strings' do
      expect('"$foo"').to produce_tokens ['VAR(foo)', 'EOS']
      expect('"${foo}"').to produce_tokens ['VAR(foo)', 'EOS']
      expect('"pre$foo"').to produce_tokens ['WORD(pre)', 'VAR(foo)', 'EOS']
      expect('"pre${foo}post"').
        to produce_tokens ['WORD(pre)', 'VAR(foo)', 'WORD(post)', 'EOS']
    end

    it 'recognises empty strings' do
      expect('\'\'').to produce_tokens ['WORD()', 'EOS']
      expect('""').to produce_tokens ['WORD()', 'EOS']
    end

    it 'recognises subshells' do
      expect('$(foo)').to produce_tokens [
        'SUBSHELL_START', 'SUBSHELL(foo)', 'SUBSHELL_END', 'EOS',
      ]
      expect('$(foo $(bar))').to produce_tokens [
        'SUBSHELL_START', 'SUBSHELL(foo $)', 'SUBSHELL(()', 'SUBSHELL(bar)',
        'SUBSHELL())', 'SUBSHELL_END', 'EOS',
      ]
    end

    it 'recognises subshells in double-quoted strings' do
      expect('"$(foo)"').to produce_tokens [
        'SUBSHELL_START', 'SUBSHELL(foo)', 'SUBSHELL_END', 'EOS',
      ]
      expect('"$(foo $(bar))"').to produce_tokens [
        'SUBSHELL_START', 'SUBSHELL(foo $)', 'SUBSHELL(()', 'SUBSHELL(bar)',
        'SUBSHELL())', 'SUBSHELL_END', 'EOS',
      ]
    end

    it 'adds an error token for unclosed strings' do
      expect('\'never ending').
        to produce_tokens ['WORD(never ending)', 'MISSING(\')', 'EOS']

      expect('"never ending').
        to produce_tokens ['WORD(never ending)', 'MISSING(")', 'EOS']
    end

    it 'adds an error token for unclosed subshells' do
      expect('$(:echo Hello').to produce_tokens [
        'SUBSHELL_START', 'SUBSHELL(:echo Hello)', 'MISSING())', 'EOS'
      ]
    end

    it 'ignores comments' do
      expect('# all one big comment').to produce_tokens ['EOS']
      expect('pre #post').to produce_tokens ['WORD(pre)', 'SPACE', 'EOS']
    end
  end
end
