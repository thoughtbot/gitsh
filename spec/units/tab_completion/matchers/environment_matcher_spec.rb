require 'spec_helper'
require 'gitsh/tab_completion/matchers/environment_matcher'

describe Gitsh::TabCompletion::Matchers::EnvironmentMatcher do
  describe '#name' do
    it 'returns the name' do
      matcher = described_class.new(double(:env), 'something', &:something)

      expect(matcher.name).to eq 'something'
    end
  end

  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env), 'something', &:something)

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns the result of yielding the environment to the block' do
      env = double(:env, git_aliases: ['graph', 'force'])
      matcher = described_class.new(env, 'alias', &:git_aliases)

      expect(matcher.completions('')).to match_array ['graph', 'force']
    end

    it 'filters the results based on the input' do
      env = double(:env, git_aliases: ['graph', 'force'])
      matcher = described_class.new(env, 'alias', &:git_aliases)

      expect(matcher.completions('g')).to match_array ['graph']
    end
  end

  describe '#eql?' do
    it 'returns true for another instance of the class with the same name' do
      foo_matcher1 = described_class.new(double(:env), 'foo', &:foo)
      foo_matcher2 = described_class.new(double(:env), 'foo', &:foo)

      expect(foo_matcher1.eql?(foo_matcher2)).to be true
    end

    it 'returns false for another instance of the class with a different name' do
      foo_matcher = described_class.new(double(:env), 'foo', &:foo)
      bar_matcher = described_class.new(double(:env), 'bar', &:bar)

      expect(foo_matcher.eql?(bar_matcher)).to be false
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(double(:env), 'foo', &:foo)
      other = double(:not_a_matcher, name: 'foo')

      expect(matcher.eql?(double)).to be false
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class with the same name' do
      foo_matcher1 = described_class.new(double(:env), 'foo', &:foo)
      foo_matcher2 = described_class.new(double(:env), 'foo', &:foo)
      bar_matcher = described_class.new(double(:env), 'bar', &:bar)

      expect(foo_matcher1.hash).to eq(foo_matcher2.hash)
      expect(foo_matcher1.hash).not_to eq(bar_matcher.hash)
    end
  end
end
