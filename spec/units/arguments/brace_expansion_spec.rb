require 'spec_helper'
require 'gitsh/arguments/brace_expansion'
require 'gitsh/arguments/string_argument'

describe Gitsh::Arguments::BraceExpansion do
  describe '#value' do
    it 'returns the values of its options' do
      argument = described_class.new([
        string_argument('foo'),
        string_argument('bar'),
      ])

      expect(argument.value(double(:env))).to eq ['foo', 'bar']
    end
  end

  describe '#==' do
    it 'returns true when the options are equal' do
      a1 = described_class.new(['a', 'b'])
      a2 = described_class.new(['a', 'b'])

      expect(a1).to eq a2
    end

    it 'returns false when the options are not equal' do
      a = described_class.new(['a', 'b'])
      b = described_class.new(['c', 'd'])

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new(['a', 'b'])
      double_a = double(options: ['a', 'b'])

      expect(arg_a).not_to eq double_a
    end
  end

  def string_argument(string)
    instance_double(Gitsh::Arguments::StringArgument, value: string)
  end
end
