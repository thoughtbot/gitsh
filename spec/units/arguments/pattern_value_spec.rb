require 'spec_helper'
require 'gitsh/arguments/pattern_value'

describe Gitsh::Arguments::PatternValue do
  describe '#expand' do
    it 'returns the given options that match the pattern' do
      value = described_class.new('f.e', 'f?e')

      result = value.expand { ['fee', 'fie', 'foe', 'fum', 'feelings'] }

      expect(result).to eq ['fee', 'fie', 'foe']
    end

    context 'when nothing matches' do
      it 'returns the original pattern' do
        value = described_class.new('f.e', 'f?e')

        result = value.expand { ['nothing relevant'] }

        expect(result).to eq ['f?e']
      end
    end
  end

  describe '#+' do
    it 'concatenates two pattern values' do
      foo = described_class.new('foo.', 'foo?')
      bar = described_class.new('bar', 'foo')

      result = foo + bar

      expect(result).to eq(described_class.new('foo.bar', 'foo?bar'))
    end

    it 'concatenates string values to pattern values' do
      foo_pattern = described_class.new('foo.', 'foo?')
      bar_string = string_value('bar')

      result = foo_pattern + bar_string

      expect(result).to eq(described_class.new('foo.bar', 'foo?bar'))
    end

    it 'escapes concatenated string values' do
      dot_pattern = described_class.new('.', '?')
      dot_string = string_value('.')

      result = dot_pattern + dot_string

      expect(result).to eq(described_class.new('.\\.', '?.'))
    end

    it 'raises for non-PatternValue arguments' do
      foo = described_class.new('foo.', 'foo?')

      expect { foo + 'bar' }.to raise_exception(ArgumentError)
    end
  end

  describe '#==' do
    it 'returns true for another PatternValue with the same pattern' do
      dot1 = described_class.new('.', '?')
      dot2 = described_class.new('.', '?')

      expect(dot1).to eq(dot2)
    end

    it 'returns false for another PatternValue with a different pattern' do
      a = described_class.new('A', 'A')
      b = described_class.new('B', 'B')

      expect(a).not_to eq(b)
    end

    it 'returns false for objects of other classes' do
      value_a = described_class.new('A', 'A')
      double_a = double(pattern: 'A', source: 'A')

      expect(value_a).not_to eq(double_a)
    end
  end
end
