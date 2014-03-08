require 'spec_helper'
require 'gitsh/completer'

describe Gitsh::Completer do
  describe '#call' do
    context 'when completing commands' do
      it 'completes commands and aliases' do
        completer = build_completer(
          input: '',
          git_commands: %w( stage stash status add commit ),
          git_aliases: %w( adder )
        )

        expect(completer.call('sta')).to eq ['stage ', 'stash ', 'status ']
        expect(completer.call('ad')).to eq ['add ', 'adder ']
      end

      it 'completes internal commands' do
        completer = build_completer(
          input: '',
          internal_commands: %w( :set :exit )
        )

        expect(completer.call(':')).to eq [':set ', ':exit ']
        expect(completer.call(':s')).to eq [':set ']
      end
    end

    context 'when completing arguments' do
      it 'completes heads when a command has been entered' do
        completer = build_completer(
          input: 'checkout ',
          repo_heads: %w( master my-feature v1.0 )
        )

        expect(completer.call('')).to include 'master ', 'my-feature ', 'v1.0 '
        expect(completer.call('m')).to include 'master ', 'my-feature '
        expect(completer.call('m')).not_to include 'v1.0 '
      end

      it 'completes head when branch include a dot' do
        completer = build_completer(
          input: 'checkout ',
          repo_heads: %w( fix-v1.5 fix-v1.6 )
        )

        expect(completer.call('fix-v1.')).to include 'fix-v1.5 ', 'fix-v1.6 '
      end

      it 'completes heads starting with :' do
        completer = build_completer(
          input: 'checkout ',
          repo_heads: %w( master my-feature )
        )

        expect(completer.call('master:m')).to include 'master:my-feature '
      end

      it 'ignores input before punctuation when completing heads' do
        completer = build_completer(
          input: 'checkout ',
          repo_heads: %w( master my-feature )
        )

        expect(completer.call('mas:')).to include 'mas:master ', 'mas:my-feature '
      end

      it 'completes paths beginning with a ~ character' do
        completer = build_completer(input: 'add ')

        expect(completer.call('~/')).to include "#{first_regular_file('~')} "
      end

      it 'completes paths containing .. and .' do
        completer = build_completer(input: 'add ')
        project_root = File.expand_path('../../../', __FILE__)
        path = File.join(project_root, 'spec/./units/../units')

        expect(completer.call("#{path}/")).to include "#{first_regular_file(path)} "
      end
    end
  end

  def build_completer(options)
    readline = stub('Readline', line_buffer: options.fetch(:input))
    env = stub('Environment', {
      git_commands: options.fetch(:git_commands, %w( add commit )),
      git_aliases: options.fetch(:git_aliases, %w( graph )),
      repo_heads: options.fetch(:repo_heads, %w( master ))
    })
    internal_command = stub('InternalCommand', {
      commands: options.fetch(:internal_commands, %w( :set :exit ))
    })
    Gitsh::Completer.new(readline, env, internal_command)
  end

  def first_regular_file(directory)
    expanded_directory = File.expand_path(directory)
    Dir["#{expanded_directory}/*"].
      find { |path| File.file?(path) }.
      sub(expanded_directory, directory)
  end
end
