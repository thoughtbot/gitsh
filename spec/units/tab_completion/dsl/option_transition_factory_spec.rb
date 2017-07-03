require 'spec_helper'
require 'gitsh/tab_completion/dsl/option_transition_factory'

describe Gitsh::TabCompletion::DSL::OptionTransitionFactory do
  describe '#build' do
    it 'adds transitions for known and unknown options' do
      unknown_option_matcher = stub_unknown_option_matcher
      start_state = double(:start_state, add_transition: nil)
      known_options_factory = double(:factory, build: nil)
      factory = described_class.new

      end_state = factory.build(
        start_state,
        known_options_factory: known_options_factory,
      )

      expect(known_options_factory).to have_received(:build).with(
        start_state,
        known_options_factory: known_options_factory,
        end_state: end_state,
      )
      expect(start_state).to have_received(:add_transition).with(
        unknown_option_matcher,
        end_state,
      )
    end

    context 'with an explicit end state' do
      it 'adds transitions for known and unknown options' do
        unknown_option_matcher = stub_unknown_option_matcher
        start_state = double(:start_state, add_transition: nil)
        end_state = double(:end_state)
        known_options_factory = double(:factory, build: nil)
        factory = described_class.new

        result = factory.build(
          start_state,
          known_options_factory: known_options_factory,
          end_state: end_state,
        )

        expect(result).to eq(end_state)
        expect(known_options_factory).to have_received(:build).with(
          start_state,
          known_options_factory: known_options_factory,
          end_state: end_state,
        )
        expect(start_state).to have_received(:add_transition).with(
          unknown_option_matcher,
          end_state,
        )
      end
    end
  end

  def stub_unknown_option_matcher
    klass = Gitsh::TabCompletion::Matchers::UnknownOptionMatcher
    matcher = instance_double(klass)
    allow(klass).to receive(:new).and_return(matcher)
    matcher
  end
end
