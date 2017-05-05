require 'spec_helper'
require 'gitsh/tab_completion/dsl/option_transition_factory'

describe Gitsh::TabCompletion::DSL::OptionTransitionFactory do
  describe '#build' do
    it 'adds a transition to the start state and returns the end state' do
      matcher = stub_matcher
      start_state = double(
        :start_state,
        add_transition: nil,
        add_text_transition: nil,
      )
      path_factory = double(:path_factory, build: nil)
      context = double(
        :context,
        options_without_arguments: [
          double(:option, name: '--verbose'),
        ],
        options_with_arguments: [
          double(:option, name: '--file', argument_factory: path_factory),
        ]
      )
      factory = described_class.new

      end_state = factory.build(start_state, context: context)

      expect(end_state).to be_a(Gitsh::TabCompletion::Automaton::State)
      expect(start_state).
        to have_received(:add_transition).with(matcher, end_state)
      expect(start_state).
        to have_received(:add_text_transition).with('--file', anything)
      expect(path_factory).to have_received(:build).with(
        anything,
        end_state: end_state,
      )
      expect(Gitsh::TabCompletion::Matchers::OptionMatcher).
        to have_received(:new).with(['--verbose'], ['--file'])
    end

    context 'given an end state' do
      it 'adds a transition between the start and end states' do
        matcher = stub_matcher
        start_state = double(
          :start_state,
          add_transition: nil,
          add_text_transition: nil,
        )
        end_state = double(:end_state)
        path_factory = double(:path_factory, build: nil)
        context = double(
          :context,
          options_without_arguments: [
            double(:option, name: '--verbose'),
          ],
          options_with_arguments: [
            double(:option, name: '--file', argument_factory: path_factory),
          ]
        )
        factory = described_class.new

        result = factory.build(
          start_state,
          end_state: end_state,
          context: context,
        )

        expect(result).to eq(end_state)
        expect(start_state).
          to have_received(:add_transition).with(matcher, end_state)
        expect(start_state).
          to have_received(:add_text_transition).with('--file', anything)
        expect(path_factory).to have_received(:build).with(
          anything,
          end_state: end_state,
        )
      end
    end
  end

  def stub_matcher
    klass = Gitsh::TabCompletion::Matchers::OptionMatcher
    matcher = instance_double(klass)
    allow(klass).to receive(:new).and_return(matcher)
    matcher
  end
end
