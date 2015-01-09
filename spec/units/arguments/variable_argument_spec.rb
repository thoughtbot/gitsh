require 'spec_helper'
require 'gitsh/arguments/variable_argument'

describe Gitsh::Arguments::VariableArgument do
  describe '#value' do
    it 'returns the value of the variable passed to the initializer' do
      env = { 'author' => 'George' }
      argument = described_class.new('author')

      expect(argument.value(env)).to eq 'George'
    end
  end
end
