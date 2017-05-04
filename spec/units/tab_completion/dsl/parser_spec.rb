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
      result = parse_single_rule(tokens([:VAR, 'alias'], [:EOS]))

      expect(result).to be_a_variable_transition
      expect(result.name).to eq('alias')
    end

    it 'parses single options' do
      result = parse_single_rule(tokens([:OPTION, '--verbose'], [:EOS]))

      expect(result).to be_a_text_transition
      expect(result.word).to eq('--verbose')
    end

    it 'parses rules with multiple words, variables, and options' do
      result = parse_single_rule(tokens(
        [:WORD, 'stash'], [:WORD, 'pop'], [:VAR, 'opt'], [:EOS]
      ))

      expect(result).to be_a_concatenation
      expect(result.parts.length).to eq(3)
      expect(result.parts.first).to be_a_text_transition
      expect(result.parts.first.word).to eq('stash')
    end

    it 'parses rules with the asterisk operator' do
      result = parse_single_rule(tokens(
        [:WORD, 'verbose'], [:STAR], [:EOS]
      ))

      expect(result).to be_a_star_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the plus operator' do
      result = parse_single_rule(tokens(
        [:WORD, 'verbose'], [:PLUS], [:EOS]
      ))

      expect(result).to be_a_plus_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the question mark operator' do
      result = parse_single_rule(tokens(
        [:WORD, 'verbose'], [:MAYBE], [:EOS]
      ))

      expect(result).to be_a_maybe_operation
      expect(result.child).to be_a_text_transition
      expect(result.child.word).to eq('verbose')
    end

    it 'parses rules with the pipe operator' do
      result = parse_single_rule(tokens(
        [:LEFT_PAREN], [:WORD, 'commit'], [:OR],
        [:WORD, 'add'], [:OR], [:VAR, 'alias'], [:RIGHT_PAREN], [:EOS]
      ))

      expect(result).to be_a_choice
      expect(result.choices.length).to eq(3)
      expect(result.choices.first).to be_a_text_transition
      expect(result.choices.first.word).to eq('commit')
      expect(result.choices.last).to be_a_variable_transition
      expect(result.choices.last.name).to eq('alias')
    end

    it 'parses rules with the pipe operator and multiple words' do
      result = parse_single_rule(tokens(
        [:LEFT_PAREN], [:WORD, 'stash'], [:WORD, 'pop'], [:OR],
        [:WORD, 'add'], [:RIGHT_PAREN], [:EOS]
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
        [:MAYBE], [:EOS]
      ))

      expect(result).to be_a_maybe_operation
      expect(result.child).to be_a_choice
      expect(result.child.choices.length).to eq(2)
    end

    it 'parses rules with options' do
      result = described_class.parse(tokens(
        [:WORD, 'push'],
        [:INDENT], [:OPTION, '--force'],
        [:INDENT], [:OPTION, '--force-with-lease'], [:VAR, 'revision'],
        [:EOS],
      ))

      rule_factory = result.rules.first
      expect(rule_factory.root).to be_a_text_transition
      expect(rule_factory.options.length).to eq(2)
      force = rule_factory.options.first
      expect(force).to be_a(Gitsh::TabCompletion::DSL::Option)
      expect(force.name).to eq('--force')
    end

    it 'parses multiple rules in the same input' do
      result = described_class.parse(tokens(
        [:WORD, 'push'], [:BLANK],
        [:WORD, 'pull'], [:BLANK],
        [:WORD, 'fetch'], [:EOS],
      ))

      expect(result).to be_a_rule_set_factory
      expect(result.rules.length).to eq(3)
      expect(result.rules.first).to be_a_rule_factory
      expect(result.rules.last).to be_a_rule_factory
    end

    def parse_single_rule(tokens)
      result = described_class.parse(tokens)
      expect(result).to be_a_rule_set_factory
      result.rules.first.root
    end

    def tokens(*tokens)
      tokens.map.with_index do |token, i|
        type, value = token
        pos = RLTK::StreamPosition.new(i, 1, i, 10, nil)
        RLTK::Token.new(type, value, pos)
      end
    end

    def be_a_rule_set_factory
      be_a(Gitsh::TabCompletion::DSL::RuleSetFactory)
    end

    def be_a_rule_factory
      be_a(Gitsh::TabCompletion::DSL::RuleFactory)
    end

    def be_a_text_transition
      be_a Gitsh::TabCompletion::DSL::TextTransitionFactory
    end

    def be_a_variable_transition
      be_a Gitsh::TabCompletion::DSL::VariableTransitionFactory
    end

    def be_a_concatenation
      be_a Gitsh::TabCompletion::DSL::ConcatenationFactory
    end

    def be_a_star_operation
      be_a Gitsh::TabCompletion::DSL::StarOperationFactory
    end

    def be_a_plus_operation
      be_a Gitsh::TabCompletion::DSL::PlusOperationFactory
    end

    def be_a_maybe_operation
      be_a Gitsh::TabCompletion::DSL::MaybeOperationFactory
    end

    def be_a_choice
      be_a Gitsh::TabCompletion::DSL::ChoiceFactory
    end
  end
end
