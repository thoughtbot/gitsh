require 'spec_helper'
require 'gitsh/tab_completion/dsl/star_operation_factory'

describe Gitsh::TabCompletion::DSL::StarOperationFactory do
  describe '#build' do
    it 'calls the child factory with the start state' do
      start_state = double(:start_state)
      context = double(:context)
      child_result = double(:child_result)
      child = double(:factory, build: child_result)
      factory = described_class.new(child)

      result = factory.build(start_state, context: context)

      expect(result).to eq child_result
      expect(child).to have_received(:build).with(
        start_state,
        end_state: start_state,
        context: context,
      )
    end
  end
end
