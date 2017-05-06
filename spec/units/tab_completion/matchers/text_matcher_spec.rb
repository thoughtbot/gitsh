require 'spec_helper'
require 'gitsh/tab_completion/matchers/text_matcher'

describe Gitsh::TabCompletion::Matchers::TextMatcher do
  describe '#match?' do
    it 'returns true when given the same word' do
      expect(described_class.new('commit').match?('commit')).to be_truthy
    end

    it 'returns false when given anything else' do
      expect(described_class.new('commit').match?('log')).to be_falsy
    end
  end

  describe '#completions' do
    it 'returns the word, if it begins with the input' do
      matcher = described_class.new('commit')

      expect(matcher.completions('foo')).to eq []
      expect(matcher.completions('')).to eq ['commit']
      expect(matcher.completions('commit')).to eq ['commit']
    end

    context 'when the word starts with "--"' do
      it 'only returns the word when the input starts with a "-"' do
        matcher = described_class.new('--')

        expect(matcher.completions('foo')).to eq []
        expect(matcher.completions('')).to eq []
        expect(matcher.completions('-')).to eq ['--']

        matcher = described_class.new('--force')

        expect(matcher.completions('foo')).to eq []
        expect(matcher.completions('')).to eq []
        expect(matcher.completions('-')).to eq ['--force']
      end
    end
  end

  describe '#eql?' do
    it 'returns true for text matchers with the same text' do
      x1 = described_class.new('x')
      x2 = described_class.new('x')

      expect(x1).to eql(x2)
    end

    it 'returns false for text matchers with different text' do
      x = described_class.new('x')
      y = described_class.new('y')

      expect(x).not_to eql(y)
    end

    it 'returns false for other types of object' do
      x = described_class.new('x')
      fake_x = double(:x, word: 'x')

      expect(x).not_to eql(fake_x)
    end
  end

  describe '#hash' do
    it 'returns the same value for instances with the same text' do
      x1 = described_class.new('x')
      x2 = described_class.new('x')

      expect(x1.hash).to eq(x2.hash)
    end

    it 'returns different values for instances with different' do
      x = described_class.new('x')
      y = described_class.new('y')

      expect(x.hash).not_to eq(y.hash)
    end
  end
end
