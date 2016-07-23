require 'spec_helper'
require 'gitsh/completion_escaper'

describe Gitsh::CompletionEscaper do
  describe '#call' do
    context 'without any quote characters' do
      it 'quotes spaces' do
        options = escape_options(
          full_input: 'add op',
          completer_input: 'op',
          unescaped_options: ['option ', 'option with spaces '],
        )

        expect(options).to eq ['option ', 'option\\ with\\ spaces ']
      end
    end

    context 'with an unclosed single quote' do
      it 'does not quote spaces and strips trailing whitespace' do
        options = escape_options(
          full_input: 'add \'op',
          completer_input: 'op',
          unescaped_options: ['option ', 'option with spaces '],
        )

        expect(options).to eq ['option', 'option with spaces']
      end
    end

    context 'with an unclosed double quote' do
      it 'does not quote spaces and strips trailing whitespace' do
        options = escape_options(
          full_input: 'add "op',
          completer_input: 'op',
          unescaped_options: ['option ', 'option with spaces '],
        )

        expect(options).to eq ['option', 'option with spaces']
      end
    end
  end

  def escape_options(options)
    full_input = options.fetch(:full_input)
    completer_input = options.fetch(:completer_input)
    unescaped_options = options.fetch(:unescaped_options)

    line_editor = double(:line_editor, line_buffer: full_input)
    completer = -> (text) { unescaped_options }
    escaper = described_class.new(completer, line_editor: line_editor)
    escaper.call(completer_input)
  end
end
