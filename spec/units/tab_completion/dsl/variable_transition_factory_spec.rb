require 'spec_helper'
require 'gitsh/tab_completion/dsl/variable_transition_factory'

describe Gitsh::TabCompletion::DSL::VariableTransitionFactory do
  describe '#build' do
    it 'adds a transition to the start state and returns the end state' do
      matcher = stub_matcher(Gitsh::TabCompletion::Matchers::OptionMatcher)
      start_state = double(:start_state, add_transition: nil)
      factory = described_class.new('opt')

      end_state = factory.build(start_state)

      expect(end_state).to be_a(Gitsh::TabCompletion::Automaton::State)
      expect(start_state).
        to have_received(:add_transition).with(matcher, end_state)
    end

    context 'given an end state' do
      it 'adds a transition between the start and end states' do
        matcher = stub_matcher(Gitsh::TabCompletion::Matchers::OptionMatcher)
        start_state = double(:start_state, add_transition: nil)
        end_state = double(:end_state)
        factory = described_class.new('commit')

        result = factory.build(start_state, end_state: end_state)

        expect(result).to eq(end_state)
        expect(start_state).
          to have_received(:add_transition).with(matcher, end_state)
      end
    end
  end

  def stub_matcher(klass)
    matcher = instance_double(klass)
    allow(klass).to receive(:new).and_return(matcher)
    matcher
  end
end
