require 'spec_helper'
require 'gitsh/arguments/single_character_glob'

describe Gitsh::Arguments::SingleCharacterGlob do
  describe '#value' do
    it 'returns a PatternValue for a single character' do
      arg = described_class.new
      env = double('env')

      expect(arg.value(env)).to eq [pattern_value(/./)]
    end
  end

  describe '#==' do
    it 'returns true when given another instance of the same class' do
      a = described_class.new
      b = described_class.new

      expect(a).to eq b
    end

    it 'returns false when given an instance of another class' do
      a = described_class.new
      b = /./

      expect(a).not_to eq b
    end
  end
end
