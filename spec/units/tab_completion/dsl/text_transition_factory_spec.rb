require 'spec_helper'
require 'gitsh/tab_completion/dsl/text_transition_factory'

describe Gitsh::TabCompletion::DSL::TextTransitionFactory do
  describe '#build' do
    it 'adds a transition to the start state and returns the end state' do
      start_state = double(:start_state, add_transition: nil)
      matcher = stub_text_matcher('commit')
      factory = described_class.new('commit')

      end_state = factory.build(start_state)

      expect(end_state).to be_a(Gitsh::TabCompletion::Automaton::State)
      expect(start_state).
        to have_received(:add_transition).with(matcher, end_state)
    end

    context 'given an end state' do
      it 'adds a transition between the start and end states' do
        start_state = double(:start_state, add_transition: nil)
        end_state = double(:end_state)
        matcher = stub_text_matcher('commit')
        factory = described_class.new('commit')

        result = factory.build(start_state, end_state: end_state)

        expect(result).to eq(end_state)
        expect(start_state).
          to have_received(:add_transition).with(matcher, end_state)
      end
    end
  end
end
