require 'spec_helper'
require 'gitsh/tab_completion/dsl/option'

describe Gitsh::TabCompletion::DSL::Option do
  describe '#has_argument?' do
    it 'returns true when an option was passed to the constructor' do
      option = described_class.new('name', double(:option))

      expect(option).to have_argument
    end

    it 'returns false when an option was not passed to the constructor' do
      option = described_class.new('name')

      expect(option).not_to have_argument
    end
  end
end
