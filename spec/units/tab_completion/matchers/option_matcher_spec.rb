require 'spec_helper'
require 'gitsh/tab_completion/matchers/option_matcher'

describe Gitsh::TabCompletion::Matchers::OptionMatcher do
  describe '#match?' do
    it 'returns true for input starting with "-"' do
      matcher = described_class.new([], [])

      expect(matcher.match?('-a')).to be_truthy
      expect(matcher.match?('--force')).to be_truthy
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
end
