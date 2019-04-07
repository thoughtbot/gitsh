require 'spec_helper'
require 'gitsh/arguments/string_value'

describe Gitsh::Arguments::StringValue do
  describe '#expand' do
    it 'returns an array containing the wrapped string' do
      value = described_class.new('test')

      expect(value.expand).to eq ['test']
    end
  end

  describe '#+' do
    it 'concatenates two string values' do
      foo = described_class.new('foo')
      bar = described_class.new('bar')

      result = foo + bar

      expect(result).to eq(described_class.new('foobar'))
    end

    it 'concatenates pattern values to string values' do
      foo_string = described_class.new('foo')
      bar_pattern = pattern_value(/bar/)

      result = foo_string + bar_pattern

      expect(result).to eq(pattern_value(/foobar/))
    end

    it 'raises for non-StringValue arguments' do
      foo = described_class.new('foo')

      expect { foo + 'bar' }.to raise_exception(ArgumentError)
    end
  end

  describe '#==' do
    it 'returns true for another StringValue with the same string' do
      a1 = described_class.new('A')
      a2 = described_class.new('A')

      expect(a1).to eq(a2)
    end

    it 'returns false for another StringValue with a different string' do
      a = described_class.new('A')
      b = described_class.new('B')

      expect(a).not_to eq(b)
    end

    it 'returns false for objects of other classes' do
      value_a = described_class.new('A')
      double_a = double(value: 'A')

      expect(value_a).not_to eq(double_a)
    end
  end
end
