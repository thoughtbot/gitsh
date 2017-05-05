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
    it 'returns the completions passed to the constructor' do
      completions = ['--force', '--force-with-lease']
      completions_with_args = ['--color']
      matcher = described_class.new(completions, completions_with_args)

      expect(matcher.completions('--')).to eq(completions)
    end
  end
end
