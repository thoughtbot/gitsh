require 'spec_helper'
require 'gitsh/registry'

describe Gitsh::Registry do
  describe 'setting and getting objects' do
    it 'allows retreival of previously set objects' do
      test_object = double(:test_object)
      Gitsh::Registry.instance[:test] = test_object

      expect(Gitsh::Registry.instance[:test]).to eq(test_object)
    end
  end

  describe '.clear' do
    it 'removes everything from the registry' do
      Gitsh::Registry.instance[:env] = double(:env)
      Gitsh::Registry.clear

      expect { Gitsh::Registry.instance[:env] }.to raise_exception(KeyError)
    end
  end
end
