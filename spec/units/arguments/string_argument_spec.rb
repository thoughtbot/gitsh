require 'spec_helper'
require 'gitsh/arguments/string_argument'

describe Gitsh::Arguments::StringArgument do
  describe '#value' do
    it 'returns the string passed to the initializer' do
      arg = described_class.new('Hello world')
      env = double('env')

      expect(arg.value(env)).to eq ['Hello world']
    end
  end

  describe '#==' do
    it 'returns true when the values of the arguments are equal' do
      a1 = described_class.new('A')
      a2 = described_class.new('A')

      expect(a1).to eq a2
    end

    it 'returns false when the values of the arguments are not equal' do
      a = described_class.new('A')
      b = described_class.new('B')

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new('A')
      double_a = double(raw_value: 'A')

      expect(arg_a).not_to eq double_a
    end
  end
end
