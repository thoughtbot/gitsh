require 'spec_helper'
require 'open3'
require 'gitsh/tab_completion/dsl'
require 'gitsh/environment'

describe Gitsh::TabCompletion::DSL do
  describe '.load' do
    it 'builds a graph of automaton states by reading the given file' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          write_file('example.txt')
          run('git init')
          run('git commit --allow-empty -m "Initial"')
          path = write_temp_completions_files([
            'add $opt* --? $path+',
            '  --all',
            '  --edit',
            '',
            'stash (apply|drop|pop|show)',
            '',
            'log $opt $revision',
            '  --color (always|never|auto)',
          ].join("\n"))
          start_state = Gitsh::TabCompletion::Automaton::State.new('start')
          env = Gitsh::Environment.new

          described_class.load(path, start_state, env)

          automaton = Gitsh::TabCompletion::Automaton.new(start_state)
          expect(automaton.completions([], '')).
            to match_array ['add', 'stash', 'log']
          expect(automaton.completions(['stash'], '')).
            to match_array ['apply', 'drop', 'pop', 'show']
          expect(automaton.completions(['add'], '')).
            to match_array ['--', '--all', '--edit', 'example.txt']
          expect(automaton.completions(['add', '--all'], '')).
            to match_array ['--', '--all', '--edit', 'example.txt']
          expect(automaton.completions(['add', '--'], '')).
            to match_array ['example.txt']
          expect(automaton.completions(['log', '--color'], '')).
            to match_array ['always', 'never', 'auto']
          expect(automaton.completions(['log', '--color', 'auto'], '')).
            to match_array ['master']
        end
      end
    end
  end

  def write_temp_completions_files(completions)
    temp_file('gitsh_completions', completions).path
  end

  def run(command)
    Open3.capture3(command)
  end
end
