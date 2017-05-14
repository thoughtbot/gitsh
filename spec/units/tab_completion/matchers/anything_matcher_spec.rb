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
end
