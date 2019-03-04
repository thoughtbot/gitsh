require 'spec_helper'
require 'gitsh/argument_list'

describe Gitsh::ArgumentList do
  describe '#length' do
    it 'returns the number of arguments' do
      argument_list = Gitsh::ArgumentList.new(['hello', 'goodbye'])

      expect(argument_list.length).to eq 2
    end
  end

  describe '#values' do
    it 'returns the values of the arguments' do
      env = double('env')
      hello_arg = spy('hello_arg', value: ['hello'])
      goodbye_arg = spy('goodbye_arg', value: ['goodbye'])
      argument_list = Gitsh::ArgumentList.new([hello_arg, goodbye_arg])

      expect(argument_list.values(env)).to eq ['hello', 'goodbye']
      expect(hello_arg).to have_received(:value).with(env)
      expect(goodbye_arg).to have_received(:value).with(env)
    end
  end
end
