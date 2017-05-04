require 'spec_helper'
require 'gitsh/tab_completion/dsl'

describe Gitsh::TabCompletion::DSL do
  describe '.load' do
    it 'builds a graph of automaton states by reading the given file' do
      path = write_temp_completions_files([
        'add $opt* --? $path+',
        '  --all',
        '  --edit'
      ].join("\n"))
      start_state = Gitsh::TabCompletion::Automaton::State.new('start')

      described_class.load(path, start_state)

      automaton = Gitsh::TabCompletion::Automaton.new(start_state)
      expect(automaton.completions([], '')).to match_array ['add']
      expect(automaton.completions(['add'], '')).
        to match_array ['--all', '--edit', 'some/path']
      expect(automaton.completions(['add', '--'], '')).
        to match_array ['some/path']
    end
  end

  def write_temp_completions_files(completions)
    temp_file('gitsh_completions', completions).path
  end
end
