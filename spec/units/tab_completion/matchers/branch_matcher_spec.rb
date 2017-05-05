require 'spec_helper'
require 'gitsh/tab_completion/matchers/branch_matcher'

describe Gitsh::TabCompletion::Matchers::BranchMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all branches' do
        env = double(:env, repo_branches: ['master', 'my-feature'])
        matcher = described_class.new(env)

        expect(matcher.completions('')).to match_array ['master', 'my-feature']
      end
    end
  end
end
