require 'spec_helper'
require 'gitsh/arguments/variable_argument'

describe Gitsh::Arguments::VariableArgument do
  describe '#value' do
    it 'returns the value of the variable passed to the initializer' do
      env = { 'author' => 'George' }
      argument = described_class.new('author')

      expect(argument.value(env)).to eq ['George']
    end
  end

  describe '#==' do
    it 'returns true when the variable names are equal' do
      a1 = described_class.new('A')
      a2 = described_class.new('A')

      expect(a1).to eq a2
    end

    it 'returns false when the variable names are not equal' do
      a = described_class.new('A')
      b = described_class.new('B')

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new('A')
      double_a = double(variable_name: 'A')

      expect(arg_a).not_to eq double_a
    end
  end
end
