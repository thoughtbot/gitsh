require 'spec_helper'
require 'gitsh/parser/character_class'
require 'parslet'

describe Gitsh::Parser::CharacterClass do
  describe '#characters' do
    it 'returns the characters passed to the initializer' do
      chars = ['a', 'e', 'i', 'o', 'u']
      vowels = described_class.new(chars)

      expect(vowels.characters).to eq chars
    end
  end

  describe '#+' do
    it 'returns a new character class combining two others' do
      a = described_class.new(['a'])
      b = described_class.new(['b'])

      result = a + b

      expect(result.characters).to eq ['a', 'b']
    end
  end

  describe '#parser_atom' do
    it 'returns a Parslet::Atom matching the chracters in the class' do
      vowels = described_class.new(['a', 'e', 'i', 'o', 'u'])

      atom = vowels.parser_atom

      expect(atom).to be_a Parslet::Atoms::Base
      expect(atom).to parse('a')
      expect(atom).not_to parse('b')
    end
  end

  describe '#to_regexp' do
    it 'returns a Regexp matching the characters in the class' do
      vowels = described_class.new(['a', 'e', 'i', 'o', 'u'])

      regexp = vowels.to_regexp

      expect(regexp).to be_a Regexp
      expect(regexp).to match 'a'
      expect(regexp).not_to match 'b'
    end

    context 'with characters that need escaping in a Regexp' do
      it 'returns a properly escaped Regexp' do
        chars = described_class.new(['^', '$'])

        regexp = chars.to_regexp

        expect(regexp).to be_a Regexp
        expect(regexp).to match '^'
        expect(regexp).to match '$'
        expect(regexp).not_to match 'a'
      end
    end
  end
end
