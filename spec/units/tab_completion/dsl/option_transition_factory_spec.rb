require 'spec_helper'
require 'gitsh/tab_completion/dsl/option_transition_factory'

describe Gitsh::TabCompletion::DSL::OptionTransitionFactory do
  describe '#build' do
    it 'adds a transition to the start state and returns the end state' do
      option_matcher = stub_option_matcher
      text_matcher = stub_text_matcher('--file')
      start_state = double(
        :start_state,
        add_transition: nil,
        add_transition: nil,
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
        to have_received(:add_transition).with(option_matcher, end_state)
      expect(start_state).
        to have_received(:add_transition).with(text_matcher, anything)
      expect(path_factory).to have_received(:build).with(
        anything,
        end_state: end_state,
      )
      expect(Gitsh::TabCompletion::Matchers::OptionMatcher).
        to have_received(:new).with(['--verbose'], ['--file'])
    end

    context 'given an end state' do
      it 'adds a transition between the start and end states' do
        option_matcher = stub_option_matcher
        text_matcher = stub_text_matcher('--file')
        start_state = double(
          :start_state,
          add_transition: nil,
          add_transition: nil,
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
          to have_received(:add_transition).with(option_matcher, end_state)
        expect(start_state).
          to have_received(:add_transition).with(text_matcher, anything)
        expect(path_factory).to have_received(:build).with(
          anything,
          end_state: end_state,
        )
      end
    end
  end
end
