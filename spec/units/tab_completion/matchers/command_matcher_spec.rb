require 'spec_helper'
require 'gitsh/tab_completion/matchers/command_matcher'

describe Gitsh::TabCompletion::Matchers::CommandMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns the available Git commands' do
      env = double(:env, git_commands: ['add', 'commit'])
      matcher = described_class.new(env)

      expect(matcher.completions('')).to match_array ['add', 'commit']
    end

    it 'filters the results based on the input' do
      env = double(:env, git_commands: ['add', 'commit'])
      matcher = described_class.new(env)

      expect(matcher.completions('ad')).to match_array ['add']
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      env = double(:env)
      internal_command = double(:internal_command)
      matcher1 = described_class.new(env, internal_command)
      matcher2 = described_class.new(env, internal_command)

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(double(:env), double(:internal_command))
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      env = double(:env)
      internal_command = double(:internal_command)
      matcher1 = described_class.new(env, internal_command)
      matcher2 = described_class.new(env, internal_command)

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
