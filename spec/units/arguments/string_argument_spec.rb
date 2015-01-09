require 'spec_helper'
require 'gitsh/arguments/string_argument'

describe Gitsh::Arguments::StringArgument do
  describe '#value' do
    it 'returns the string passed to the initializer' do
      arg = described_class.new('Hello world')
      env = stub('env')

      expect(arg.value(env)).to eq 'Hello world'
    end
  end
end
