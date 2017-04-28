require 'spec_helper'
require 'gitsh/tab_completion/escaper'

describe Gitsh::TabCompletion::Escaper do
  describe '#escape' do
    context 'without any quote characters' do
      it 'escapes spaces, slashes, quotes, operators, etc.' do
        line_editor = double(:line_editor, completion_quote_character: nil)
        escaper = described_class.new(line_editor)

        expect(escaper.escape(%q(option))).to eq %q(option)
        expect(escaper.escape(%q(with space))).to eq %q(with\ space)
        expect(escaper.escape(%q("quotes"))).to eq %q(\"quotes\")
        expect(escaper.escape(%q('quotes'))).to eq %q(\'quotes\')
        expect(escaper.escape(%q(slash\\))).to eq %q(slash\\\\)
        expect(escaper.escape(%q($var_like))).to eq %q(\$var_like)
        expect(escaper.escape(%q(a&b))).to eq %q(a\&b)
        expect(escaper.escape(%q(a|b))).to eq %q(a\|b)
        expect(escaper.escape(%q(a;b))).to eq %q(a\;b)
        expect(escaper.escape(%q(#comment-like))).to eq %q(\#comment-like)
      end
    end

    context 'with an unclosed single quote' do
      it 'escapes slashes and single quotes' do
        line_editor = double(:line_editor, completion_quote_character: '\'')
        escaper = described_class.new(line_editor)

        expect(escaper.escape(%q(option))).to eq %q(option)
        expect(escaper.escape(%q(with space))).to eq %q(with space)
        expect(escaper.escape(%q("quotes"))).to eq %q("quotes")
        expect(escaper.escape(%q('quotes'))).to eq %q(\'quotes\')
        expect(escaper.escape(%q(slash\\))).to eq %q(slash\\\\)
        expect(escaper.escape(%q($var_like))).to eq %q($var_like)
        expect(escaper.escape(%q(a&b))).to eq %q(a&b)
        expect(escaper.escape(%q(a|b))).to eq %q(a|b)
        expect(escaper.escape(%q(a;b))).to eq %q(a;b)
        expect(escaper.escape(%q(#comment-like))).to eq %q(#comment-like)
      end
    end

    context 'with an unclosed double quote' do
      it 'escapes slashes, double quotes, and $' do
        line_editor = double(:line_editor, completion_quote_character: '"')
        escaper = described_class.new(line_editor)

        expect(escaper.escape(%q(option))).to eq %q(option)
        expect(escaper.escape(%q(with space))).to eq %q(with space)
        expect(escaper.escape(%q("quotes"))).to eq %q(\"quotes\")
        expect(escaper.escape(%q('quotes'))).to eq %q('quotes')
        expect(escaper.escape(%q(slash\\))).to eq %q(slash\\\\)
        expect(escaper.escape(%q($var_like))).to eq %q(\$var_like)
        expect(escaper.escape(%q(a&b))).to eq %q(a&b)
        expect(escaper.escape(%q(a|b))).to eq %q(a|b)
        expect(escaper.escape(%q(a;b))).to eq %q(a;b)
        expect(escaper.escape(%q(#comment-like))).to eq %q(#comment-like)
      end
    end
  end

  describe '#unescape' do
    context 'without any quote characters' do
      it 'unescapes spaces, slashes, quotes, operators, etc.' do
        line_editor = double(:line_editor, completion_quote_character: nil)
        escaper = described_class.new(line_editor)

        expect(escaper.unescape(%q(option))).to eq %q(option)
        expect(escaper.unescape(%q(with\ space))).to eq %q(with space)
        expect(escaper.unescape(%q(\"quotes\"))).to eq %q("quotes")
        expect(escaper.unescape(%q(\'quotes\'))).to eq %q('quotes')
        expect(escaper.unescape(%q(slash\\\\))).to eq %q(slash\\)
        expect(escaper.unescape(%q(\$var_like))).to eq %q($var_like)
        expect(escaper.unescape(%q(a\&b))).to eq %q(a&b)
        expect(escaper.unescape(%q(a\|b))).to eq %q(a|b)
        expect(escaper.unescape(%q(a\;b))).to eq %q(a;b)
        expect(escaper.unescape(%q(\#comment-like))).to eq %q(#comment-like)
      end
    end

    context 'with an unclosed single quote' do
      it 'unescapes slashes and single quotes' do
        line_editor = double(:line_editor, completion_quote_character: '\'')
        escaper = described_class.new(line_editor)

        expect(escaper.unescape(%q(option))).to eq %q(option)
        expect(escaper.unescape(%q(with\ space))).to eq %q(with\ space)
        expect(escaper.unescape(%q(\"quotes\"))).to eq %q(\"quotes\")
        expect(escaper.unescape(%q(\'quotes\'))).to eq %q('quotes')
        expect(escaper.unescape(%q(slash\\\\))).to eq %q(slash\\)
        expect(escaper.unescape(%q(\$var_like))).to eq %q(\$var_like)
        expect(escaper.unescape(%q(a\&b))).to eq %q(a\&b)
        expect(escaper.unescape(%q(a\|b))).to eq %q(a\|b)
        expect(escaper.unescape(%q(a\;b))).to eq %q(a\;b)
        expect(escaper.unescape(%q(\#comment-like))).to eq %q(\#comment-like)
      end
    end

    context 'with an unclosed double quote' do
      it 'unescapes slashes, double quotes, and $' do
        line_editor = double(:line_editor, completion_quote_character: '"')
        escaper = described_class.new(line_editor)

        expect(escaper.unescape(%q(option))).to eq %q(option)
        expect(escaper.unescape(%q(with\ space))).to eq %q(with\ space)
        expect(escaper.unescape(%q(\"quotes\"))).to eq %q("quotes")
        expect(escaper.unescape(%q(\'quotes\'))).to eq %q(\'quotes\')
        expect(escaper.unescape(%q(slash\\\\))).to eq %q(slash\\)
        expect(escaper.unescape(%q(\$var_like))).to eq %q($var_like)
        expect(escaper.unescape(%q(a\&b))).to eq %q(a\&b)
        expect(escaper.unescape(%q(a\|b))).to eq %q(a\|b)
        expect(escaper.unescape(%q(a\;b))).to eq %q(a\;b)
        expect(escaper.unescape(%q(\#comment-like))).to eq %q(\#comment-like)
      end
    end
  end
end
