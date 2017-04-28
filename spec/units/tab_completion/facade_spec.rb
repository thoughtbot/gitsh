require 'spec_helper'
require 'gitsh/tab_completion/facade'

describe Gitsh::TabCompletion::Facade do
  describe '#call' do
    it 'presents a convenient interface to the world' do
      facade = described_class.new(double(:line_editor), double(:env))

      expect(facade).to respond_to(:call)
    end
  end
end
