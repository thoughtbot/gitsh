require 'spec_helper'
require 'gitsh/tab_completion/matchers/tag_matcher'

describe Gitsh::TabCompletion::Matchers::TagMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all tags' do
        register_env(repo_tags: ['v1.0', 'v1.1'])
        matcher = described_class.new

        expect(matcher.completions('')).to match_array ['v1.0', 'v1.1']
      end
    end

    context 'given a partial tag name' do
      it 'returns all tag names matching the input' do
        register_env(repo_tags: ['v1.0', 'v2.0'])
        matcher = described_class.new

        expect(matcher.completions('v')).
          to match_array ['v1.0', 'v2.0']
        expect(matcher.completions('v1')).
          to match_array ['v1.0']
        expect(matcher.completions('foo')).
          to match_array []
      end
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
