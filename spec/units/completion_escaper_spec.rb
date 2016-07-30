require 'spec_helper'
require 'gitsh/completion_escaper'

describe Gitsh::CompletionEscaper do
  describe '#call' do
    context 'without any quote characters' do
      it 'escapes spaces, slashes, quotes, operators, etc.' do
        options = escape_options(
          quote_character: nil,
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option),
              %q(with space),
              %q("quotes"),
              %q('quotes'),
              %q(slash\\),
              %q($var_like),
              %q(a&b),
              %q(a|b),
              %q(a;b),
              %q(#comment-like),
            ]
          end,
        )

        expect(options).to eq [
          %q(option),
          %q(with\ space),
          %q(\"quotes\"),
          %q(\'quotes\'),
          %q(slash\\\\),
          %q(\$var_like),
          %q(a\&b),
          %q(a\|b),
          %q(a\;b),
          %q(\#comment-like),
        ]
      end

      it 'unescapes the input before passing it to the completer' do
        completer_argument = nil
        completer = -> (text) do
          completer_argument = text
          ['some file.txt']
        end
        options = escape_options(
          quote_character: nil,
          completer_input: 'some\\ f',
          completer: completer,
        )

        expect(completer_argument).to eq 'some f'
        expect(options).to eq ['some\\ file.txt']
      end

      it 'recognises escaped escape characters' do
        completer_argument = nil
        completer = -> (text) do
          completer_argument = text
          []
        end
        escape_options(
          quote_character: nil,
          completer_input: 'some\\\\ f',
          completer: completer,
        )

        expect(completer_argument).to eq 'some\\ f'
      end

      it 'only unescapes valid escape sequences' do
        completer_argument = nil
        completer = -> (text) do
          completer_argument = text
          []
        end
        escape_options(
          quote_character: nil,
          completer_input: 'not\\escaped',
          completer: completer,
        )

        expect(completer_argument).to eq 'not\\escaped'
      end
    end

    context 'with an unclosed single quote' do
      it 'escapes slashes and single quotes' do
        options = escape_options(
          quote_character: "'",
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option),
              %q(with space),
              %q("quotes"),
              %q('quotes'),
              %q(slash\\),
              %q($var_like),
              %q(a&b),
              %q(a|b),
              %q(a;b),
              %q(#comment-like),
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
      it 'escapes slashes, double quotes, and $' do
        options = escape_options(
          quote_character: '"',
          completer_input: 'op',
          completer: -> (_) do
            [
              %q(option),
              %q(with space),
              %q("quotes"),
              %q('quotes'),
              %q(slash\\),
              %q($var_like),
              %q(a&b),
              %q(a|b),
              %q(a;b),
              %q(#comment-like),
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
    quote_character = options.fetch(:quote_character)
    completer_input = options.fetch(:completer_input)
    completer = options.fetch(:completer)

    line_editor = double(
      :line_editor,
      completion_quote_character: quote_character,
    )
    escaper = described_class.new(completer, line_editor: line_editor)
    escaper.call(completer_input)
  end
end
