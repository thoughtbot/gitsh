require 'spec_helper'
require 'gitsh/tab_completion/automaton_factory'

describe Gitsh::TabCompletion::AutomatonFactory do
  describe '.build' do
    it 'loads the tab completion DSL file' do
      config_directory = '/tmp/etc/gitsh'
      env = double(:env, config_directory: config_directory)
      start_state = stub_automaton_state
      automaton = stub_automaton
      stub_dsl_loading
      config_path = File.join(config_directory, 'completions')

      result = described_class.build(env)

      expect(result).to eq(automaton)
      expect(Gitsh::TabCompletion::Automaton).
        to have_received(:new).with(start_state)
      expect(Gitsh::TabCompletion::DSL).
        to have_received(:load).with(config_path, start_state, env)
    end
  end

  def stub_automaton_state
    stub_class(Gitsh::TabCompletion::Automaton::State)
  end

  def stub_automaton
    stub_class(Gitsh::TabCompletion::Automaton)
  end

  def stub_dsl_loading
    allow(Gitsh::TabCompletion::DSL).to receive(:load)
  end

  def stub_class(klass)
    instance = instance_double(klass)
    allow(klass).to receive(:new).and_return(instance)
    instance
  end
end
