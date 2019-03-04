require 'spec_helper'
require 'gitsh/arguments/composite_argument'

describe Gitsh::Arguments::CompositeArgument do
  describe '#value' do
    it 'returns the concatenated values of the arguments passed to the initializer' do
      env = double('env')
      first_argument = double('first_argument', value: 'Hello')
      second_argument = double('second_argument', value: 'World')
      argument = described_class.new([first_argument, second_argument])

      expect(argument.value(env)).to eq ['HelloWorld']
      expect(first_argument).to have_received(:value).with(env)
      expect(second_argument).to have_received(:value).with(env)
    end
  end

  describe '#==' do
    it 'returns true when the parts are equal' do
      abc1 = described_class.new(['A', 'B', 'C'])
      abc2 = described_class.new(['A', 'B', 'C'])

      expect(abc1).to eq abc2
    end

    it 'returns false when the parts are not equal' do
      a = described_class.new(['A'])
      b = described_class.new(['B'])

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new(['A'])
      double_a = double(parts: ['A'])

      expect(arg_a).not_to eq double_a
    end
  end
end
