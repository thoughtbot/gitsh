require 'spec_helper'
require 'gitsh/tab_completion/matchers/command_matcher'

describe Gitsh::TabCompletion::Matchers::CommandMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:internal_command))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns the available commands (Git, internal, and aliases)' do
      register_env(
        git_commands: ['add', 'commit'],
        git_aliases: ['graph', 'force'],
      )
      internal_command = double(
        :internal_command,
        commands: [':echo', ':help'],
      )
      matcher = described_class.new(internal_command)

      expect(matcher.completions('')).to match_array [
        'add', 'commit',
        'graph', 'force',
        ':echo', ':help',
      ]
    end

    it 'filters the results based on the input' do
      register_env(
        git_commands: ['add', 'grep'],
        git_aliases: ['graph', 'force'],
      )
      internal_command = double(
        :internal_command,
        commands: [':echo', ':help'],
      )
      matcher = described_class.new(internal_command)

      expect(matcher.completions('gr')).to match_array [
        'graph', 'grep',
      ]
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      internal_command = double(:internal_command)
      matcher1 = described_class.new(internal_command)
      matcher2 = described_class.new(internal_command)

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(double(:internal_command))
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      internal_command = double(:internal_command)
      matcher1 = described_class.new(internal_command)
      matcher2 = described_class.new(internal_command)

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
