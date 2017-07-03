require 'spec_helper'
require 'gitsh/tab_completion/dsl/parser'

describe Gitsh::TabCompletion::DSL::Parser do
  describe '.parse' do
    it 'parses single words' do
      result = parse_single_rule(tokens([:WORD, 'stash'], [:EOS]))

      expect(result).to be_a_text_transition
      expect(result.word).to eq('stash')
    end

    it 'parses single variables' do
      result = parse_single_rule(tokens([:VAR, 'revision'], [:EOS]))

      expect(result).to be_a_variable_transition
      expect(result.matcher).to be_a_revision_matcher
    end

    it 'parses the special $opt variable' do
      result = parse_single_rule(tokens([:OPT_VAR], [:EOS]))

      expect(result).to be_an_option_transition
    end

    it 'parses single options' do
      result = parse_single_rule(tokens([:OPTION, '--verbose'], [:EOS]))

      expect(result).to be_a_text_transition
      expect(result.word).to eq('--verbose')
    end

    it 'parses rules with multiple words, variables, and options' do
      result = parse_single_rule(tokens(
        [:WORD, 'stash'], [:WORD, 'pop'], [:OPTION, '--verbose'],
        [:VAR, 'revision'], [:EOS],
      ))

      expect(result).to be_a_concatenation
      expect(result.parts.length).to eq(4)
      expect(result.parts.first).to be_a_text_transition
      expect(result.parts.first.word).to eq('stash')
      expect(result.parts[2]).to be_a_text_transition
      expect(result.parts[2].word).to eq('--verbose')
    end

    it 'parses rules with the asterisk operator' do
      result = parse_single_rule(tokens([:WORD, 'verbose'], [:STAR], [:EOS]))

      expect(result).to be_a_star_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the plus operator' do
      result = parse_single_rule(tokens([:WORD, 'verbose'], [:PLUS], [:EOS]))

      expect(result).to be_a_plus_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the question mark operator' do
      result = parse_single_rule(tokens([:WORD, 'verbose'], [:MAYBE], [:EOS]))

      expect(result).to be_a_maybe_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the pipe operator' do
      result = parse_single_rule(tokens(
        [:LEFT_PAREN], [:WORD, 'commit'], [:OR],
        [:WORD, 'add'], [:OR], [:VAR, 'path'], [:RIGHT_PAREN], [:EOS],
      ))

      expect(result).to be_a_choice
      expect(result.choices.length).to eq(3)
      expect(result.choices.first).to be_a_text_transition
      expect(result.choices.first.word).to eq('commit')
      expect(result.choices.last).to be_a_variable_transition
      expect(result.choices.last.matcher).to be_a_path_matcher
    end

    it 'parses rules with the pipe operator and multiple words' do
      result = parse_single_rule(tokens(
        [:LEFT_PAREN], [:WORD, 'stash'], [:WORD, 'pop'], [:OR],
        [:WORD, 'add'], [:RIGHT_PAREN], [:EOS],
      ))

      expect(result).to be_a_choice
      expect(result.choices.length).to eq(2)
      expect(result.choices.first).to be_a_concatenation
      expect(result.choices.first.parts.first).to be_a_text_transition
      expect(result.choices.first.parts.first.word).to eq('stash')
    end

    it 'parses rules combining the pipe operator and a post-fix operator' do
      result = parse_single_rule(tokens(
        [:LEFT_PAREN], [:WORD, 'add'], [:OR], [:WORD, 'commit'], [:RIGHT_PAREN],
        [:PLUS], [:EOS],
      ))

      expect(result).to be_a_plus_operation
      expect(result.child).to be_a_choice
      expect(result.child.choices.length).to eq(2)
    end

    it 'parses rules with options' do
      result = described_class.parse(tokens(
        [:WORD, 'push'], [:OPT_VAR],
        [:INDENT], [:OPTION, '--force'],
        [:INDENT], [:OPTION, '--remote'], [:VAR, 'remote'],
        [:EOS],
      ), gitsh_env: double(:env))

      rule_factory = result.rules.first
      expect(rule_factory.options).to be_a_choice

      expect(rule_factory.options.choices.length).to eq(2)

      first_argument_choice = rule_factory.options.choices.first
      last_argument_choice = rule_factory.options.choices.last

      expect(first_argument_choice).to be_a_text_transition
      expect(first_argument_choice.word).to eq('--force')
      expect(last_argument_choice).to be_a_concatenation
      expect(last_argument_choice.parts.length).to eq(2)
      expect(last_argument_choice.parts.first).to be_a_text_transition
      expect(last_argument_choice.parts.last).to be_a_variable_transition
    end

    it 'parses multiple rules in the same input' do
      result = described_class.parse(tokens(
        [:WORD, 'push'], [:BLANK],
        [:WORD, 'pull'], [:BLANK], [:BLANK],
        [:WORD, 'fetch'], [:EOS],
      ), gitsh_env: double(:env))

      expect(result).to be_a_rule_set_factory
      expect(result.rules.length).to eq(3)
      expect(result.rules.first).to be_a_rule_factory
      expect(result.rules.last).to be_a_rule_factory
    end
  end

  def parse_single_rule(tokens)
    env = double(:env)
    result = described_class.parse(tokens, gitsh_env: env)
    expect(result).to be_a_rule_set_factory
    result.rules.first.root
  end

  def be_a_rule_set_factory
    be_a(Gitsh::TabCompletion::DSL::RuleSetFactory)
  end

  def be_a_rule_factory
    be_a(Gitsh::TabCompletion::DSL::RuleFactory)
  end

  def be_a_text_transition
    be_a(Gitsh::TabCompletion::DSL::TextTransitionFactory)
  end

  def be_a_variable_transition
    be_a(Gitsh::TabCompletion::DSL::VariableTransitionFactory)
  end

  def be_an_option_transition
    be_a(Gitsh::TabCompletion::DSL::OptionTransitionFactory)
  end

  def be_a_concatenation
    be_a(Gitsh::TabCompletion::DSL::ConcatenationFactory)
  end

  def be_a_star_operation
    be_a Gitsh::TabCompletion::DSL::StarOperationFactory
  end

  def be_a_plus_operation
    be_a(Gitsh::TabCompletion::DSL::PlusOperationFactory)
  end

  def be_a_maybe_operation
    be_a(Gitsh::TabCompletion::DSL::MaybeOperationFactory)
  end

  def be_a_choice
    be_a(Gitsh::TabCompletion::DSL::ChoiceFactory)
  end

  def be_a_revision_matcher
    be_a(Gitsh::TabCompletion::Matchers::RevisionMatcher)
  end

  def be_a_path_matcher
    be_a(Gitsh::TabCompletion::Matchers::PathMatcher)
  end
end
