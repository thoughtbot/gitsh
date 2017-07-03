require 'spec_helper'
require 'gitsh/tab_completion/matchers/unknown_option_matcher'

describe Gitsh::TabCompletion::Matchers::UnknownOptionMatcher do
  describe '#match?' do
    it 'returns true for input starting with "-"' do
      matcher = described_class.new

      expect(matcher.match?('-a')).to be_truthy
      expect(matcher.match?('--force')).to be_truthy
      expect(matcher.match?('--untracked-files')).to be_truthy
    end

    it 'returns false for "-" and "--"' do
      matcher = described_class.new

      expect(matcher.match?('-')).to be_falsey
      expect(matcher.match?('--')).to be_falsey
    end

    it 'returns false for input not starting with "-"' do
      matcher = described_class.new

      expect(matcher.match?('')).to be_falsey
      expect(matcher.match?('push')).to be_falsey
    end
  end

  describe '#completions' do
    it 'returns an empty array for any input' do
      matcher = described_class.new

      expect(matcher.completions('')).to eq([])
      expect(matcher.completions('--')).to eq([])
      expect(matcher.completions('--force')).to eq([])
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      matcher1 = described_class.new
      matcher2 = described_class.new

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      matcher1 = described_class.new
      matcher2 = described_class.new

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
