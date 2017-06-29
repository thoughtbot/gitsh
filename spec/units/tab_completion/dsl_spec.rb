require 'spec_helper'
require 'gitsh/tab_completion/dsl'

describe Gitsh::TabCompletion::DSL do
  describe '.load' do
    it 'builds a graph of automaton states by reading the given file' do
      path = write_temp_completions_file([
        'stash (apply|drop|pop|show)',
      ].join("\n"))
      start_state = Gitsh::TabCompletion::Automaton::State.new('start')
      env = Gitsh::Environment.new

      described_class.load(path, start_state, env)

      automaton = Gitsh::TabCompletion::Automaton.new(start_state)
      expect(automaton.completions([], '')).
        to match_array ['stash']
      expect(automaton.completions(['stash'], '')).
        to match_array ['apply', 'drop', 'pop', 'show']
    end

    context 'with a path to a file that does not exist' do
      it 'does not explode' do
        path = '/not/a/real/path'
        start_state = Gitsh::TabCompletion::Automaton::State.new('start')
        env = Gitsh::Environment.new

        expect { described_class.load(path, start_state, env) }.
          not_to raise_exception
      end
    end
  end

  def write_temp_completions_file(completions)
    temp_file('gitsh_completions', completions).path
  end
end
