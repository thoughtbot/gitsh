require 'spec_helper'
require 'gitsh/tab_completion/dsl/choice_factory'

describe Gitsh::TabCompletion::DSL::ChoiceFactory do
  describe '#build' do
    it 'applies all of the choice factories with the same end state' do
      start_state = double(:start_state)
      first_choice = double(:first_choice, build: nil)
      second_choice = double(:second_choice, build: nil)
      context = double(:context)
      factory = described_class.new([first_choice, second_choice])

      end_state = factory.build(start_state, context: context)

      expect(first_choice).to have_received(:build).with(
        start_state,
        end_state: end_state,
        context: context,
      )
      expect(second_choice).to have_received(:build).with(
        start_state,
        end_state: end_state,
        context: context,
      )
    end

    context 'given an end state' do
      it 'applies all of the choice factories with the given end state' do
        start_state = double(:start_state)
        end_state = double(:end_state)
        first_choice = double(:first_choice, build: nil)
        second_choice = double(:second_choice, build: nil)
        context = double(:context)
        factory = described_class.new([first_choice, second_choice])

        result = factory.build(
          start_state,
          context: context,
          end_state: end_state,
        )

        expect(result).to eq end_state
        expect(first_choice).to have_received(:build).with(
          start_state,
          end_state: end_state,
          context: context,
        )
        expect(second_choice).to have_received(:build).with(
          start_state,
          end_state: end_state,
          context: context,
        )
      end
    end
  end
end
