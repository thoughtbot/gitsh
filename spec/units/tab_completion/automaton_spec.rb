require 'spec_helper'
require 'gitsh/tab_completion/matchers/text_matcher'
require 'gitsh/tab_completion/automaton'

describe Gitsh::TabCompletion::Automaton do
  describe '#completions' do
    it 'delegates to a Session' do
      expected_result = double(:result)
      session = stub_session(completions: expected_result)
      start_state = described_class::State.new('start')
      automaton = described_class.new(start_state)

      result = automaton.completions(['foo', 'bar'], 'prefix')

      expect(result).to eq(expected_result)
      expect(described_class::Session).to have_received(:new).with(start_state)
      expect(session).to have_received(:step_through).with(['foo', 'bar'])
      expect(session).to have_received(:completions).with('prefix')
    end
  end

  describe '#accept_visitor' do
    it 'passes each state and transition to the visitor once' do
      #       ,--- a ---> (1)
      #       |
      # ---> (0)
      #       |
      #       '---------> (2) --- b ---> (3)

      state_0 = described_class::State.new(0)
      state_1 = described_class::State.new(1)
      state_2 = described_class::State.new(2)
      state_3 = described_class::State.new(3)
      matcher_a = add_text_transition(state_0, 'a', state_1)
      state_0.add_free_transition(state_2)
      matcher_b = add_text_transition(state_2, 'b', state_3)
      automaton = described_class.new(state_0)
      visitor = double(
        :visitor,
        visit_state: nil,
        visit_transition: nil,
        visit_free_transition: nil,
      )

      automaton.accept_visitor(visitor)

      expect(visitor).to have_received(:visit_state).with(state_0).once
      expect(visitor).to have_received(:visit_state).with(state_1).once
      expect(visitor).to have_received(:visit_state).with(state_2).once
      expect(visitor).to have_received(:visit_state).with(state_3).once
      expect(visitor).to have_received(:visit_transition).
        with(state_0, state_1, matcher_a).once
      expect(visitor).to have_received(:visit_transition).
        with(state_2, state_3, matcher_b).once
      expect(visitor).to have_received(:visit_free_transition).
        with(state_0, state_2).once
    end

    it 'handles loops' do
      #       ,--- a ---,
      #       |         v
      # ---> (0)       (1)
      #       ^         |
      #       '--- b ---'

      state_0 = described_class::State.new(0)
      state_1 = described_class::State.new(1)
      matcher_a = add_text_transition(state_0, 'a', state_1)
      matcher_b = add_text_transition(state_1, 'b', state_0)
      automaton = described_class.new(state_0)
      visitor = double(
        :visitor,
        visit_state: nil,
        visit_transition: nil,
        visit_free_transition: nil,
      )

      automaton.accept_visitor(visitor)

      expect(visitor).to have_received(:visit_state).with(state_0).once
      expect(visitor).to have_received(:visit_state).with(state_1).once
      expect(visitor).to have_received(:visit_transition).
        with(state_0, state_1, matcher_a).once
      expect(visitor).to have_received(:visit_transition).
        with(state_1, state_0, matcher_b).once
    end

    it 'handles multiple routes to the same node' do
      #       ,--- a ---,
      #       |         v
      # ---> (0)       (1)
      #       |         ^
      #       '---------'

      state_0 = described_class::State.new(0)
      state_1 = described_class::State.new(1)
      add_text_transition(state_0, 'a', state_1)
      state_0.add_free_transition(state_1)
      automaton = described_class.new(state_0)
      visitor = double(
        :visitor,
        visit_state: nil,
        visit_transition: nil,
        visit_free_transition: nil,
      )

      automaton.accept_visitor(visitor)

      expect(visitor).to have_received(:visit_state).with(state_0).once
      expect(visitor).to have_received(:visit_state).with(state_1).once
    end
  end

  def add_text_transition(start_state, word, end_state)
    Gitsh::TabCompletion::Matchers::TextMatcher.new(word).tap do |matcher|
      start_state.add_transition(matcher, end_state)
    end
  end

  def add_fallback_transition(start_state, word, end_state)
    Gitsh::TabCompletion::Matchers::TextMatcher.new(word).tap do |matcher|
      start_state.add_fallback_transition(matcher, end_state)
    end
  end

  def stub_session(attrs)
    session = instance_double(described_class::Session, attrs)
    allow(session).to receive(:step_through).and_return(session)
    allow(described_class::Session).to receive(:new).and_return(session)
    session
  end
end
