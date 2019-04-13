require 'spec_helper'
require 'gitsh/registry'

describe Gitsh::Registry do
  describe 'setting and getting objects' do
    it 'allows retreival of previously set objects' do
      test_object = double(:test_object)
      Gitsh::Registry[:test] = test_object

      expect(Gitsh::Registry[:test]).to eq(test_object)
    end
  end

  describe '.clear' do
    it 'removes everything from the registry' do
      Gitsh::Registry[:env] = double(:env)
      Gitsh::Registry.clear

      expect { Gitsh::Registry[:env] }.to raise_exception(KeyError)
    end
  end
end
