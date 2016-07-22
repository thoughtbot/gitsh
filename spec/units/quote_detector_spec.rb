require 'spec_helper'
require 'gitsh/quote_detector'

describe Gitsh::QuoteDetector do
  describe '#call' do
    context 'for an escaped character' do
      it 'returns true' do
        expect(detect('a\\ b', 2)).to be true
        expect(detect('\\ b', 1)).to be true
      end
    end

    context 'for an unescaped character' do
      it 'returns false' do
        expect(detect('a b', 1)).to be false
        expect(detect(' b', 0)).to be false
      end
    end

    context 'for repeated escape characters' do
      it 'returns true for odd numbers' do
        expect(detect('a\\\\ b', 3)).to be false
        expect(detect('a\\\\\\ b', 4)).to be true
        expect(detect('a\\\\\\\\ b', 5)).to be false

        expect(detect('\\\\ b', 2)).to be false
        expect(detect('\\\\\\ b', 3)).to be true
        expect(detect('\\\\\\\\ b', 4)).to be false
      end
    end
  end

  def detect(text, index)
    described_class.new.call(text, index)
  end
end
