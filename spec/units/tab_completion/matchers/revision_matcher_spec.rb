require 'spec_helper'
require 'gitsh/tab_completion/matchers/revision_matcher'

describe Gitsh::TabCompletion::Matchers::RevisionMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns the names of all heads' do
        env = double(:env, repo_heads: ['master', 'my-feature'])
        matcher = described_class.new(env)

        expect(matcher.completions('')).to match_array ['master', 'my-feature']
      end
    end

    context 'given input containing a prefix' do
      it 'returns the name of all heads with the prefix added' do
        env = double(:env, repo_heads: ['master', 'my-feature'])
        matcher = described_class.new(env)

        expect(matcher.completions('master..')).
          to match_array ['master..master', 'master..my-feature']
        expect(matcher.completions('HEAD:')).
          to match_array ['HEAD:master', 'HEAD:my-feature']
      end
    end

    context 'given a partial revision name' do
      it 'returns all heads matching the input' do
        env = double(:env, repo_heads: ['master', 'my-feature'])
        matcher = described_class.new(env)

        expect(matcher.completions('m')).
          to match_array ['master', 'my-feature']
        expect(matcher.completions('my')).
          to match_array ['my-feature']
        expect(matcher.completions('HEAD:m')).
          to match_array ['HEAD:master', 'HEAD:my-feature']
        expect(matcher.completions('HEAD:my')).
          to match_array ['HEAD:my-feature']
        expect(matcher.completions('HEAD:foo')).
          to match_array []
      end
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      env = double(:env)
      matcher1 = described_class.new(env)
      matcher2 = described_class.new(env)

      expect(matcher1).to eql(matcher2)
    end

    it 'returns false when given an instance of any other class' do
      matcher = described_class.new(double(:env))
      other = double(:not_a_matcher)

      expect(matcher).not_to eql(other)
    end
  end

  describe '#hash' do
    it 'returns the same value for all instances of the class' do
      env = double(:env)
      matcher1 = described_class.new(env)
      matcher2 = described_class.new(env)

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
