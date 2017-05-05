require 'spec_helper'
require 'gitsh/tab_completion/dsl/rule_factory'

describe Gitsh::TabCompletion::DSL::RuleFactory do
  describe '#build' do
    it 'delegates to the rule\'s root factory' do
      start_state = double(:start_state)
      root = double(:factory, build: nil)
      factory = described_class.new(root, double(:options))

      factory.build(start_state)

      expect(root).to have_received(:build).with(start_state, context: factory)
    end
  end
end
