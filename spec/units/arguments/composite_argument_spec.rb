require 'spec_helper'
require 'gitsh/arguments/composite_argument'

describe Gitsh::Arguments::CompositeArgument do
  describe '#value' do
    it 'returns the concatenated values of the arguments passed to the initializer' do
      env = double('env')
      first_argument = double(
        'first_argument',
        value: [string_value('Hello')],
      )
      second_argument = double(
        'second_argument',
        value: [string_value('World')],
      )
      argument = described_class.new([first_argument, second_argument])

      expect(argument.value(env)).to eq [string_value('HelloWorld')]
      expect(first_argument).to have_received(:value).with(env)
      expect(second_argument).to have_received(:value).with(env)
    end

    context 'when it contains arguments with multiple values' do
      it 'produces the concatenated product of the various values' do
        env = double('env')
        argument = described_class.new([
          double('first_argument', value: [string_value('h')]),
          double(
            'second_argument',
            value: [string_value('i'), string_value('o')],
          ),
          double('third_argument', value: [string_value('p')]),
        ])

        expect(argument.value(env)).
          to eq [string_value('hip'), string_value('hop')]
      end
    end
  end

  describe '#==' do
    it 'returns true when the parts are equal' do
      abc1 = described_class.new([string_value('A'), string_value('B')])
      abc2 = described_class.new([string_value('A'), string_value('B')])

      expect(abc1).to eq abc2
    end

    it 'returns false when the parts are not equal' do
      a = described_class.new([string_value('A')])
      b = described_class.new([string_value('B')])

      expect(a).not_to eq b
    end

    it 'returns false when the other object has a different class' do
      arg_a = described_class.new([string_value('A')])
      double_a = double(parts: [string_value('A')])

      expect(arg_a).not_to eq double_a
    end
  end
end
