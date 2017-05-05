require 'spec_helper'
require 'gitsh/tab_completion/dsl/concatenation_factory'

describe Gitsh::TabCompletion::DSL::ConcatenationFactory do
  describe '#build' do
    it 'connects the various parts together' do
      rule_factory = double(:rule_factory)
      start_state = double(:start_state)
      end_state_1 = double(:end_state_1)
      part_1 = double(:factory, build: end_state_1)
      end_state_2 = double(:end_state_2)
      part_2 = double(:factory, build: end_state_2)
      factory = described_class.new([part_1, part_2])

      result = factory.build(start_state, context: rule_factory)

      expect(part_1).to have_received(:build).
        with(start_state, context: rule_factory)
      expect(part_2).to have_received(:build).
        with(end_state_1, context: rule_factory)
      expect(result).to eq(end_state_2)
    end

    context 'given an end state' do
      it 'connects the various parts together, with a free transition to the end state' do
        rule_factory = double(:rule_factory)
        start_state = double(:start_state)
        end_state = double(:end_state)
        end_state_1 = double(:end_state_1)
        part_1 = double(:factory, build: end_state_1)
        end_state_2 = double(:end_state_2, add_free_transition: nil)
        part_2 = double(:factory, build: end_state_2)
        factory = described_class.new([part_1, part_2])

        result = factory.build(
          start_state,
          context: rule_factory,
          end_state: end_state,
        )

        expect(part_1).to have_received(:build).
          with(start_state, context: rule_factory)
        expect(part_2).to have_received(:build).
          with(end_state_1, context: rule_factory)
        expect(end_state_2).to have_received(:add_free_transition).
          with(end_state)
        expect(result).to eq(end_state)
      end
    end
  end
end
