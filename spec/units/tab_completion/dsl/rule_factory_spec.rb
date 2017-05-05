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

  describe '#options_without_arguments' do
    it 'returns the subset of options with no argument' do
      option_with_argument = double(:argument, has_argument?: true)
      option_without_argument = double(:no_argument, has_argument?: false)

      factory = described_class.new(
        double(:root),
        [option_without_argument, option_with_argument],
      )

      expect(factory.options_without_arguments).to eq [option_without_argument]
    end
  end

  describe '#options_with_arguments' do
    it 'returns the subset of options with an argument' do
      option_with_argument = double(:argument, has_argument?: true)
      option_without_argument = double(:no_argument, has_argument?: false)

      factory = described_class.new(
        double(:root),
        [option_without_argument, option_with_argument],
      )

      expect(factory.options_with_arguments).to eq [option_with_argument]
    end
  end
end
