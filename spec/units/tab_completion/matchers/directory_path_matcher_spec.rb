require 'spec_helper'
require 'gitsh/tab_completion/matchers/directory_path_matcher'

describe Gitsh::TabCompletion::Matchers::DirectoryPathMatcher do
  describe '#match?' do
    it 'always returns true' do
      matcher = described_class.new(double(:env))

      expect(matcher.match?('foo')).to be_truthy
      expect(matcher.match?('')).to be_truthy
    end
  end

  describe '#completions' do
    it 'returns directory paths based on the input' do
      in_a_temporary_directory do
        make_directory('foo')
        make_directory('foo/sub')
        write_file('foo/first.txt')
        write_file('foo/second.txt')
        write_file('first.txt')
        write_file('second.txt')
        matcher = described_class.new(double(:env))

        expect(matcher.completions('')).to match_array ['foo/']
        expect(matcher.completions('f')).to match_array ['foo/']
        expect(matcher.completions('foo')).to match_array ['foo/']
        expect(matcher.completions('foo/')).to match_array ['foo/sub/']
      end
    end
  end
end
