require 'spec_helper'
require 'gitsh/tab_completion/matchers/text_matcher'
require 'gitsh/tab_completion/automaton'

describe Gitsh::TabCompletion::Automaton::Session do
  describe '#step' do
    context 'for a deterministic automaton' do
      it 'updates the current states and returns self' do
        # --> (0) --- a ---> (1)

        state_0 = build_state(0)
        state_1 = build_state(1)
        add_text_transition(state_0, 'a', state_1)
        session = build_session(state_0)

        expect(session.current_states).to eq [state_0].to_set

        result = session.step('a')

        expect(result).to eq(session)
        expect(session.current_states).to eq [state_1].to_set

        result = session.step('b')

        expect(result).to eq(session)
        expect(session.current_states).to be_empty
      end
    end

    context 'for a non-deterministic automaton' do
      it 'updates the current states and returns self' do
        #       ,--- a ---,     ,--- b ---,
        #       |         |     |         |
        # ---> (0)        |--> (1)        |--> (2)
        #       |         |     |         |
        #       '---------'     '---------'

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'a', state_1)
        state_0.add_free_transition(state_1)
        add_text_transition(state_1, 'b', state_2)
        state_1.add_free_transition(state_2)
        session = build_session(state_0)

        expect(session.current_states).to eq [state_0, state_1, state_2].to_set

        result = session.step('a')

        expect(result).to eq(session)
        expect(session.current_states).to eq [state_1, state_2].to_set

        result = session.step('b')

        expect(result).to eq(session)
        expect(session.current_states).to eq [state_2].to_set

        result = session.step('c')

        expect(result).to eq(session)
        expect(session.current_states).to eq [].to_set
      end
    end

    context 'for a deterministic automaton with a fallback transition' do
      it 'uses the fallback transition when there is no other match' do
        # --> (0) --- a ------> (1)
        #      |
        #      '-- fallback --> (2)

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'a', state_1)
        add_fallback_transition(state_0, 'x', state_2)

        expect(build_session(state_0).step('a').current_states).
          to eq [state_1].to_set
        expect(build_session(state_0).step('b').current_states).
          to eq [state_2].to_set
      end
    end

    context 'for a non-deterministic automaton with a fallback transition' do
      it 'uses the fallback transition when there is no other match' do
        # --> (0) --- a ------> (1) -----> (2)
        #      |
        #      '-- fallback --> (3) -----> (4)

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        state_3 = build_state(3)
        state_4 = build_state(4)

        add_text_transition(state_0, 'a', state_1)
        state_1.add_free_transition(state_2)
        add_fallback_transition(state_0, 'x', state_3)
        state_3.add_free_transition(state_4)

        expect(build_session(state_0).step('a').current_states)
          .to eq [state_1, state_2].to_set
        expect(build_session(state_0).step('b').current_states).
          to eq [state_3, state_4].to_set
      end
    end
  end

  describe '#step_through' do
    context 'for a deterministic automaton' do
      it 'updates the current states and returns self' do
        # --> (0) --- a ---> (1) --- b ---> (2)

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'a', state_1)
        add_text_transition(state_1, 'b', state_2)
        session = build_session(state_0)

        result = session.step_through(['a', 'b'])

        expect(result).to eq(session)
        expect(session.current_states).to eq [state_2].to_set
      end
    end
  end

  describe '#completions' do
    context 'for a deterministic automaton' do
      it 'returns possible completions' do
        #       ,--- aa ---> (1)
        #       |
        # ---> (0)
        #       |
        #       '--- bb ---> (2)

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'aa', state_1)
        add_text_transition(state_0, 'ab', state_2)
        session = build_session(state_0)

        expect(session.completions('')).to eq ['aa', 'ab']
        expect(session.completions('a')).to eq ['aa', 'ab']
        expect(session.completions('ab')).to eq ['ab']
        expect(session.completions('a')).to eq ['aa', 'ab']

        session.step('aa')

        expect(session.completions('')).to eq []

        session.step('foo')

        expect(session.completions('')).to eq []
      end
    end

    context 'for a non-deterministic automaton' do
      it 'returns possible completions' do
        #       ,--- aa ---,
        #       |          v
        # ---> (0)        (1) --- bb ---> (2)
        #       |          ^
        #       '----------'

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'aa', state_1)
        state_0.add_free_transition(state_1)
        add_text_transition(state_1, 'bb', state_2)
        session = build_session(state_0)

        expect(session.completions('')).to eq ['aa', 'bb']
        expect(session.completions('a')).to eq ['aa']

        session.step('aa')

        expect(session.completions('')).to eq ['bb']

        session.step('foo')

        expect(session.completions('')).to eq []
      end

      it 'includes matches from fallback transitions' do
        # --> (0) --- a ------> (1)
        #      |
        #      '-- fallback --> (2)

        state_0 = build_state(0)
        state_1 = build_state(1)
        state_2 = build_state(2)
        add_text_transition(state_0, 'a', state_1)
        add_fallback_transition(state_0, 'x', state_2)
        session = build_session(state_0)

        expect(session.completions('')).to eq ['a', 'x']
      end
    end

    it 'filters out duplicates' do
      #       ,--- aa ---,
      #       |          v
      # ---> (0)        (1) --- aa ---> (2)
      #       |          ^
      #       '----------'

      state_0 = build_state(0)
      state_1 = build_state(1)
      state_2 = build_state(2)
      add_text_transition(state_0, 'aa', state_1)
      state_0.add_free_transition(state_1)
      add_text_transition(state_1, 'aa', state_2)
      session = build_session(state_0)

      expect(session.completions('')).to eq ['aa']
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

  def build_session(start_state)
    Gitsh::TabCompletion::Automaton::Session.new(start_state)
  end

  def build_state(name)
    Gitsh::TabCompletion::Automaton::State.new(name)
  end
end
