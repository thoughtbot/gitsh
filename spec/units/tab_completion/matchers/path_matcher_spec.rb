require 'spec_helper'
require 'gitsh/tab_completion/matchers/path_matcher'

describe Gitsh::TabCompletion::Matchers::PathMatcher do
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
    it 'returns paths based on the input' do
      in_a_temporary_directory do
        make_directory('foo')
        write_file('foo/first.txt')
        write_file('foo/second.txt')
        write_file('first.txt')
        write_file('second.txt')
        matcher = described_class.new(double(:env))

        expect(matcher.completions('')).
          to match_array ['foo/', 'first.txt', 'second.txt']
        expect(matcher.completions('f')).to match_array ['foo/', 'first.txt']
        expect(matcher.completions('foo')).to match_array ['foo/']
        expect(matcher.completions('foo/')).
          to match_array ['foo/first.txt', 'foo/second.txt']
      end
    end
  end

  describe '#eql?' do
    it 'returns true when given another instance of the same class' do
      matcher1 = described_class.new(double(:env))
      matcher2 = described_class.new(double(:env))

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
      matcher1 = described_class.new(double(:env))
      matcher2 = described_class.new(double(:env))

      expect(matcher1.hash).to eq(matcher2.hash)
    end
  end
end
