require 'spec_helper'
require 'gitsh/tab_completion/matchers/anything_matcher'

describe Gitsh::TabCompletion::Matchers::AnythingMatcher do
  describe '#match?' do
    it 'returns true when the input does not begin with "-"' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end

    it 'returns false when the input begins with "-"' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('-a')).to be_falsey
      expect(matcher.match?('--')).to be_falsey
      expect(matcher.match?('--force')).to be_falsey
    end
  end

  describe '#completions' do
    it 'returns an empty array' do
      matcher = described_class.new(double(:env))

      expect(matcher.completions('foo')).to eq []
      expect(matcher.completions('')).to eq []
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      env = double(:env)
      matcher1 = described_class.new(env)
      matcher2 = described_class.new(env)

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(double(:env))
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(double)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      env = double(:env)
      matcher1 = described_class.new(env)
      matcher2 = described_class.new(env)

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
