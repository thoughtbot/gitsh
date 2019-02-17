require 'spec_helper'
require 'gitsh/tab_completion/dsl/fallback_transition_factory'

describe Gitsh::TabCompletion::DSL::FallbackTransitionFactory do
  describe '#build' do
    it 'adds a fallback transition to the start state and returns the end state' do
      start_state = double(:start_state, add_fallback_transition: nil)
      matcher = double(:matcher)
      factory = described_class.new(matcher)

      end_state = factory.build(start_state)

      expect(end_state).to be_a(Gitsh::TabCompletion::Automaton::State)
      expect(start_state).
        to have_received(:add_fallback_transition).with(matcher, end_state)
    end

    context 'given an end state' do
      it 'adds a fallback transition between the start and end states' do
        start_state = double(:start_state, add_fallback_transition: nil)
        end_state = double(:end_state)
        matcher = double(:matcher)
        factory = described_class.new(matcher)

        result = factory.build(start_state, end_state: end_state)

        expect(result).to eq(end_state)
        expect(start_state).
          to have_received(:add_fallback_transition).with(matcher, end_state)
      end
    end
  end
end
