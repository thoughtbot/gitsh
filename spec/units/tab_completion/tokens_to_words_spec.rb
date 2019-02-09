require 'spec_helper'
require 'gitsh/tab_completion/tokens_to_words'

describe Gitsh::TabCompletion::TokensToWords do
  describe '#call' do
    it 'converts an array of tokens to an array of words' do
      expect(call(
        [:WORD, 'foo'], [:SPACE], [:WORD, 'bar'],
      )).to eq ['foo', 'bar']

      expect(call(
        [:WORD, 'foo'], [:WORD, 'bar'],
      )).to eq ['foobar']
    end

    it 'supports variables' do
      expect(call(
        [:WORD, 'foo'], [:VAR, 'bar'], [:WORD, 'baz'],
      )).to eq ['foo${bar}baz']
    end
  end

  def call(*token_descriptions)
    Gitsh::TabCompletion::TokensToWords.call(tokens(*token_descriptions))
  end
end
