require 'spec_helper'
require 'gitsh/tab_completion/vizualisation'

describe Gitsh::TabCompletion::Vizualisation do
  describe '#to_dot' do
    it 'produces a description of the state graph in dot format' do
      start_state = state('start')
      end_state = state('end')
      add_text_transition(start_state, 'a', end_state)

      dot = described_class.new(start_state).to_dot

      expect(dot).to include("#{start_state.object_id} [ label=\"start\" ]")
      expect(dot).to include("#{end_state.object_id} [ label=\"end\" ]")
      expect(dot).to include(
        %Q{#{start_state.object_id} -> #{end_state.object_id} [ label="\\"a\\"" ]}
      )
    end
  end

  describe '#summary' do
    it 'produces a description of the size of the graph' do
      start_state = state('start')
      end_state = state('end')
      add_text_transition(start_state, 'a', end_state)

      summary = described_class.new(start_state).summary

      expect(summary).to include('2 nodes')
      expect(summary).to include('1 edge')
    end
  end

  def state(label)
    Gitsh::TabCompletion::Automaton::State.new(label)
  end

  def add_text_transition(start_state, word, end_state)
    start_state.add_transition(
      Gitsh::TabCompletion::Matchers::TextMatcher.new(word),
      end_state,
    )
  end
end
