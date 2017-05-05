require 'spec_helper'
require 'gitsh/tab_completion/matchers/alias_matcher'

describe Gitsh::TabCompletion::Matchers::AliasMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns the available aliases' do
      env = double(:env, git_aliases: ['graph', 'force'])
      matcher = described_class.new(env)

      expect(matcher.completions('anything')).to match_array ['graph', 'force']
    end
  end
end
