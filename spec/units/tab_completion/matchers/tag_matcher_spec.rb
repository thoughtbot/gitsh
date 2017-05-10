require 'spec_helper'
require 'gitsh/tab_completion/matchers/tag_matcher'

describe Gitsh::TabCompletion::Matchers::TagMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all tags' do
        env = double(:env, repo_tags: ['v0.1', 'v0.2'])
        matcher = described_class.new(env)

        expect(matcher.completions('')).to match_array ['v0.1', 'v0.2']
      end
    end
  end
end
