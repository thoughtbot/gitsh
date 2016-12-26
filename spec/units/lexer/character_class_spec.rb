require 'spec_helper'
require 'gitsh/lexer/character_class'

describe Gitsh::Lexer::CharacterClass do
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

  describe '#to_negative_regexp' do
    it 'returns a Regexp excluding the characters in the class' do
      vowels = described_class.new(['a', 'e', 'i', 'o', 'u'])

      regexp = vowels.to_negative_regexp

      expect(regexp).to be_a Regexp
      expect(regexp).not_to match 'a'
      expect(regexp).to match 'b'
    end

    context 'with characters that need escaping in a Regexp' do
      it 'returns a properly escaped Regexp' do
        chars = described_class.new(['^', '$'])

        regexp = chars.to_negative_regexp

        expect(regexp).to be_a Regexp
        expect(regexp).not_to match '^'
        expect(regexp).not_to match '$'
        expect(regexp).to match 'a'
      end
    end
  end
end
