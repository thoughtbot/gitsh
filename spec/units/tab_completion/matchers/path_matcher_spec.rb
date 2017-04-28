require 'spec_helper'
require 'gitsh/tab_completion/matchers/path_matcher'

describe Gitsh::TabCompletion::Matchers::PathMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns paths based on the input' do
      in_a_temporary_directory do
        make_directory('foo')
        write_file('foo/first.txt')
        write_file('foo/second.txt')
        write_file('first.txt')
        matcher = described_class.new

        expect(matcher.completions('f')).to match_array ['foo/', 'first.txt']
        expect(matcher.completions('foo')).to match_array ['foo/']
        expect(matcher.completions('foo/')).
          to match_array ['foo/first.txt', 'foo/second.txt']
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

      expect(matcher).not_to eql(double)
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
