require 'spec_helper'
require 'gitsh/tab_completion/matchers/branch_matcher'

describe Gitsh::TabCompletion::Matchers::BranchMatcher do
  describe '#match?' do
    it 'always returns true' do
      register_env
      matcher = described_class.new

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all branches' do
        register_env(repo_branches: ['master', 'my-feature'])
        matcher = described_class.new

        expect(matcher.completions('')).to match_array ['master', 'my-feature']
      end
    end

    context 'given a partial branch name' do
      it 'returns all branch names matching the input' do
        register_env(repo_branches: ['master', 'my-feature'])
        matcher = described_class.new

        expect(matcher.completions('m')).
          to match_array ['master', 'my-feature']
        expect(matcher.completions('my')).
          to match_array ['my-feature']
        expect(matcher.completions('foo')).
          to match_array []
      end
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      register_env
      matcher1 = described_class.new
      matcher2 = described_class.new

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      register_env
      matcher = described_class.new
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      register_env
      matcher1 = described_class.new
      matcher2 = described_class.new

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
