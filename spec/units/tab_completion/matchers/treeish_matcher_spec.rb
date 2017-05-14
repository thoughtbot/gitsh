require 'spec_helper'
require 'gitsh/tab_completion/matchers/treeish_matcher'

describe Gitsh::TabCompletion::Matchers::TreeishMatcher do
  describe '#match?' do
    it 'returns true when the input does not begin with "-"' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end

    it 'returns false when the input begins with "-"' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('-a')).to be_falsey
      expect(matcher.match?('--')).to be_falsey
      expect(matcher.match?('--force')).to be_falsey
    end
  end

  describe '#completions' do
    context 'given blank input' do
      it 'returns a combination of heads and paths' do
        in_a_temporary_directory do
          write_file('main.c')
          write_file('other.c')
          env = double(:env, repo_heads: ['master', 'feature'])
          matcher = described_class.new(env)

          expect(matcher.completions('')).
            to match_array ['master', 'feature', 'main.c', 'other.c']
          expect(matcher.completions('m')).
            to match_array ['master', 'feature', 'main.c']
        end
      end
    end

    context 'given input containing a colon' do
      it 'returns the paths with the prefix added' do
        in_a_temporary_directory do
          write_file('main.c')
          write_file('other.c')
          env = double(:env, repo_heads: nil)
          matcher = described_class.new(env)

          expect(matcher.completions('master:')).
            to match_array ['master:main.c', 'master:other.c']
          expect(matcher.completions(':')).
            to match_array [':main.c', ':other.c']
          expect(matcher.completions(':0:')).
            to match_array [':0:main.c', ':0:other.c']
        end
      end
    end
  end
end
