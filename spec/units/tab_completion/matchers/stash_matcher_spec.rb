require 'spec_helper'
require 'gitsh/tab_completion/matchers/stash_matcher'

describe Gitsh::TabCompletion::Matchers::StashMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all stashes' do
        env = double(:env, repo_stashes: ['stash@{0}', 'stash@{1}'])
        matcher = described_class.new(env)

        expect(matcher.completions('')).
          to match_array ['stash@{0}', 'stash@{1}']
      end
    end
  end
end
