require 'spec_helper'
require 'gitsh/arguments/pattern_value'

describe Gitsh::Arguments::PatternValue do
  describe '#expand' do
    it 'returns the given options that match the pattern' do
      value = described_class.new(/f.e/)

      result = value.expand { ['fee', 'fie', 'foe', 'fum'] }

      expect(result).to eq ['fee', 'fie', 'foe']
    end

    it 'returns only complete matches'

    context 'when nothing matches' do
      it 'returns the original pattern'
    end
  end

  describe '#+' do
    it 'concatenates two pattern values' do
      foo = described_class.new(/foo/)
      bar = described_class.new(/bar/)

      result = foo + bar

      expect(result).to eq(described_class.new(/foobar/))
    end

    it 'concatenates string values to pattern values' do
      foo_pattern = described_class.new(/foo/)
      bar_string = string_value('bar')

      result = foo_pattern + bar_string

      expect(result).to eq(described_class.new(/foobar/))
    end

    it 'raises for non-PatternValue arguments' do
      foo = described_class.new(/foo/)

      expect { foo + /bar/ }.to raise_exception(ArgumentError)
    end
  end

  describe '#==' do
    it 'returns true for another PatternValue with the same pattern' do
      dot1 = described_class.new(/./)
      dot2 = described_class.new(/./)

      expect(dot1).to eq(dot2)
    end

    it 'returns false for another PatternValue with a different pattern' do
      a = described_class.new(/A/)
      b = described_class.new(/B/)

      expect(a).not_to eq(b)
    end

    it 'returns false for objects of other classes' do
      value_a = described_class.new(/A/)
      double_a = double(pattern: /A/)

      expect(value_a).not_to eq(double_a)
    end
  end
end
