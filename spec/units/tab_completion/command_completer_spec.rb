require 'spec_helper'
require 'gitsh/tab_completion/command_completer'

describe Gitsh::TabCompletion::CommandCompleter do
  describe '#call' do
    it 'produces completions using an Automaton' do
      automaton = build_automaton(completions: ['my-stash'])
      completer = described_class.new(
        build_line_editor,
        ['stash', 'drop'],
        'my-',
        automaton,
        build_escaper,
      )

      completions = completer.call

      expect(completions).to eq ['my-stash']
      expect(automaton).
        to have_received(:completions).
        with(['stash', 'drop'], 'my-')
    end

    it 'unescapes input and escapes output' do
      automaton = build_automaton(completions: ['my stash'])
      completer = described_class.new(
        build_line_editor,
        ['stash', 'drop'],
        'my\ s',
        automaton,
        build_escaper('my s' => 'my\ s', 'my stash' => 'my\ stash'),
      )

      completions = completer.call

      expect(completions).to eq ['my\ stash']
      expect(automaton).to have_received(:completions).with(anything, 'my s')
    end

    context 'with multiple matching options' do
      it 'configures the line editor to append quotes and spaces' do
        line_editor = build_line_editor
        completer = described_class.new(
          line_editor,
          ['add'],
          'some',
          build_automaton(completions: ['somedir/', 'somefile.txt']),
          build_escaper,
        )

        completer.call

        expect(line_editor).
          to have_received(:completion_append_character=).with(' ')
        expect(line_editor).
          to have_received(:completion_suppress_quote=).with(false)
      end
    end

    context 'with a single matching option that is not a directory path' do
      it 'configures the line editor to append quotes and spaces' do
        line_editor = build_line_editor
        completer = described_class.new(
          line_editor,
          ['add'],
          'some',
          build_automaton(completions: ['somefile.txt']),
          build_escaper,
        )

        completer.call

        expect(line_editor).
          to have_received(:completion_append_character=).with(' ')
        expect(line_editor).
          to have_received(:completion_suppress_quote=).with(false)
      end
    end

    context 'with a single matching option that is a directory path' do
      it 'configures the line editor not to append quotes or spaces' do
        line_editor = build_line_editor
        completer = described_class.new(
          line_editor,
          ['add'],
          'some',
          build_automaton(completions: ['somedir/']),
          build_escaper,
        )

        completer.call

        expect(line_editor).
          to have_received(:completion_append_character=).with(nil)
        expect(line_editor).
          to have_received(:completion_suppress_quote=).with(true)
      end
    end
  end

  def build_line_editor
    double(
      'LineEditor',
      :completion_append_character= => nil,
      :completion_suppress_quote= => nil,
    )
  end

  def build_automaton(methods)
    double('Automaton', methods)
  end

  def build_escaper(escapes = {})
    escaper = double('Escaper')
    allow(escaper).to receive(:escape) { |string| string }
    allow(escaper).to receive(:unescape) { |string| string }

    escapes.each do |unescaped, escaped|
      allow(escaper).to receive(:escape).with(unescaped).and_return(escaped)
      allow(escaper).to receive(:unescape).with(escaped).and_return(unescaped)
    end

    escaper
  end
end
