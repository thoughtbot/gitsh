require 'spec_helper'
require 'gitsh/arguments/composite_argument'

describe Gitsh::Arguments::CompositeArgument do
  describe '#value' do
    it 'returns the concatenated values of the arguments passed to the initializer' do
      env = stub('env')
      first_argument = stub('first_argument', value: 'Hello')
      second_argument = stub('second_argument', value: 'World')
      argument = described_class.new([first_argument, second_argument])

      expect(argument.value(env)).to eq 'HelloWorld'
      expect(first_argument).to have_received(:value).with(env)
      expect(second_argument).to have_received(:value).with(env)
    end
  end
end
