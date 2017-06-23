require 'spec_helper'
require 'gitsh/tab_completion/matchers/option_matcher'

describe Gitsh::TabCompletion::Matchers::OptionMatcher do
  describe '#match?' do
    it 'returns true for input starting with "-"' do
      matcher = described_class.new([], [])

      expect(matcher.match?('-a')).to be_truthy
      expect(matcher.match?('--force')).to be_truthy
      expect(matcher.match?('--untracked-files')).to be_truthy
    end

    it 'returns false for "-" and "--"' do
      matcher = described_class.new([], [])

      expect(matcher.match?('-')).to be_falsy
      expect(matcher.match?('--')).to be_falsy
    end

    it 'returns false for input not starting with "-"' do
      matcher = described_class.new([], [])

      expect(matcher.match?('push')).to be_falsy
    end

    it 'returns false for completions that require arguments' do
      matcher = described_class.new([], ['--color'])

      expect(matcher.match?('--color')).to be_falsy
    end
  end

  describe '#completions' do
    context 'when the input starts with "-"' do
      it 'returns the completions matching the input' do
        completions = ['--force', '--force-with-lease', '--verbose']
        completions_with_args = []
        matcher = described_class.new(completions, completions_with_args)

        expect(matcher.completions('--')).to eq(completions)
        expect(matcher.completions('-')).to eq(completions)
        expect(matcher.completions('--v')).to eq(['--verbose'])
      end
    end

    context 'when the input does not start with "-"' do
      it 'returns nothing' do
        completions = ['--force', '--force-with-lease']
        completions_with_args = []
        matcher = described_class.new(completions, completions_with_args)

        expect(matcher.completions('')).to eq([])
        expect(matcher.completions('foo')).to eq([])
      end
    end
  end

  describe '#eql?' do
    it 'returns true for another instance of the class with the same options' do
      matcher1 = described_class.new(['a', 'b'], ['c', 'd'])
      matcher2 = described_class.new(['a', 'b'], ['c', 'd'])

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false for another instance of the class with different options' do
      matcher1 = described_class.new(['a', 'b'], ['c', 'd'])
      matcher2 = described_class.new(['a', 'b'], ['x', 'y'])
      matcher3 = described_class.new(['x', 'y'], ['c', 'd'])

      expect(matcher1).not_to eql(matcher2)
      expect(matcher1).not_to eql(matcher3)
      expect(matcher2).not_to eql(matcher3)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(['a', 'b'], ['c', 'd'])
      other = double(
        :not_a_matcher,
        options_without_args: ['a', 'b'],
        options_with_args: ['c', 'd'],
      )

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class with the options' do
      matcher1 = described_class.new(['a', 'b'], ['c', 'd'])
      matcher2 = described_class.new(['a', 'b'], ['c', 'd'])
      matcher3 = described_class.new(['w', 'x'], ['y', 'z'])

      expect(matcher1.hash).to eq(matcher2.hash)
      expect(matcher1.hash).not_to eq(matcher3.hash)
    end
  end
end
