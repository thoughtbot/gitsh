require 'spec_helper'
require 'gitsh/completion_escaper'

describe Gitsh::CompletionEscaper do
  describe '#call' do
    context 'without any quote characters' do
      it 'escapes spaces, slashes, quotes, operators, etc.' do
        options = escape_options(
          full_input: 'add op',
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option ),
              %q(with space ),
              %q("quotes" ),
              %q('quotes' ),
              %q(slash\ ),
              %q($var_like ),
              %q(a&b ),
              %q(a|b ),
              %q(a;b ),
              %q(#comment-like ),
            ]
          end,
        )

        expect(options).to eq [
          %q(option ),
          %q(with\ space ),
          %q(\"quotes\" ),
          %q(\'quotes\' ),
          %q(slash\\\\ ),
          %q(\$var_like ),
          %q(a\&b ),
          %q(a\|b ),
          %q(a\;b ),
          %q(\#comment-like ),
        ]
      end

      it 'unescapes the input before passing it to the completer' do
        completer_argument = nil
        completer = -> (text) do
          completer_argument = text
          ['some file.txt ']
        end
        options = escape_options(
          full_input: 'add some\\ f',
          completer_input: 'some\\ f',
          completer: completer,
        )

        expect(completer_argument).to eq 'some f'
        expect(options).to eq ['some\\ file.txt ']
      end
    end

    context 'with an unclosed single quote' do
      it 'escapes slashes and single quotes, and strips trailing whitespace' do
        options = escape_options(
          full_input: 'add \'op',
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option ),
              %q(with space ),
              %q("quotes" ),
              %q('quotes' ),
              %q(slash\ ),
              %q($var_like ),
              %q(a&b ),
              %q(a|b ),
              %q(a;b ),
              %q(#comment-like ),
            ]
          end,
        )

        expect(options).to eq [
          %q(option),
          %q(with space),
          %q("quotes"),
          %q(\'quotes\'),
          %q(slash\\\\),
          %q($var_like),
          %q(a&b),
          %q(a|b),
          %q(a;b),
          %q(#comment-like),
        ]
      end
    end

    context 'with an unclosed double quote' do
      it 'escapes slashes, double quotes, and $, and strips trailing whitespace' do
        options = escape_options(
          full_input: 'add "op',
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option ),
              %q(with space ),
              %q("quotes" ),
              %q('quotes' ),
              %q(slash\ ),
              %q($var_like ),
              %q(a&b ),
              %q(a|b ),
              %q(a;b ),
              %q(#comment-like ),
            ]
          end,
        )

        expect(options).to eq [
          %q(option),
          %q(with space),
          %q(\"quotes\"),
          %q('quotes'),
          %q(slash\\\\),
          %q(\$var_like),
          %q(a&b),
          %q(a|b),
          %q(a;b),
          %q(#comment-like),
        ]
      end
    end
  end

  def escape_options(options)
    full_input = options.fetch(:full_input)
    completer_input = options.fetch(:completer_input)
    completer = options.fetch(:completer)

    line_editor = double(:line_editor, line_buffer: full_input)
    escaper = described_class.new(completer, line_editor: line_editor)
    escaper.call(completer_input)
  end
end
