require 'rltk'
require 'gitsh/tab_completion/dsl/choice_factory'
require 'gitsh/tab_completion/dsl/concatenation_factory'
require 'gitsh/tab_completion/dsl/maybe_operation_factory'
require 'gitsh/tab_completion/dsl/null_factory'
require 'gitsh/tab_completion/dsl/option_transition_factory'
require 'gitsh/tab_completion/dsl/plus_operation_factory'
require 'gitsh/tab_completion/dsl/rule_factory'
require 'gitsh/tab_completion/dsl/rule_set_factory'
require 'gitsh/tab_completion/dsl/star_operation_factory'
require 'gitsh/tab_completion/dsl/text_transition_factory'
require 'gitsh/tab_completion/dsl/variable_transition_factory'
require 'gitsh/tab_completion/matchers/command_matcher'
require 'gitsh/tab_completion/matchers/path_matcher'
require 'gitsh/tab_completion/matchers/remote_matcher'
require 'gitsh/tab_completion/matchers/revision_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class Parser < RLTK::Parser
        VARIABLE_TO_MATCHER_CLASS = {
          'command' => Matchers::CommandMatcher,
          'path' => Matchers::PathMatcher,
          'remote' => Matchers::RemoteMatcher,
          'revision' => Matchers::RevisionMatcher,
        }.freeze

        class Environment < RLTK::Parser::Environment
          def initialize(gitsh_env = nil)
            @gitsh_env = gitsh_env
            super()
          end

          def maybe_concatenate(factories)
            if factories.length > 1
              ConcatenationFactory.new(factories)
            else
              factories.first
            end
          end

          def matcher_for_variable(var_name)
            @_matchers ||= {}
            @_matchers[var_name] ||= build_matcher(var_name)
          end

          private

          attr_reader :gitsh_env

          def build_matcher(var_name)
            VARIABLE_TO_MATCHER_CLASS.fetch(var_name).new(gitsh_env)
          end
        end

        def self.parse(tokens, opts = {})
          super(
            tokens,
            opts.merge(env: Environment.new(opts.fetch(:gitsh_env))),
          )
        end

        production(:rule_set) do
          clause('rule') do |rule_factory|
            RuleSetFactory.new([rule_factory])
          end
          clause('rules') do |rule_factories|
            RuleSetFactory.new(rule_factories)
          end
        end

        production(:rules) do
          clause('.rule BLANK+ .rule') { |rule1, rule2| [rule1, rule2] }
          clause('.rules BLANK+ .rule') { |rules, rule| rules + [rule] }
        end

        production(:rule) do
          clause('command_format') do |factory|
            RuleFactory.new(factory, NullFactory.new)
          end
          clause('command_format opt_var_value+') do |factory, options|
            RuleFactory.new(factory, ChoiceFactory.new(options))
          end
        end

        production(:command_format, 'term+') do |factories|
          maybe_concatenate(factories)
        end

        production(:opt_var_value) do
          clause('INDENT .option') { |option| option }
          clause('INDENT .option .term') do |option, argument_factory|
            ConcatenationFactory.new([option, argument_factory])
          end
        end

        production(:term) do
          clause('item') { |factory| factory }
          clause('.item STAR') { |factory| StarOperationFactory.new(factory) }
          clause('.item PLUS') { |factory| PlusOperationFactory.new(factory) }
          clause('.item MAYBE') { |factory| MaybeOperationFactory.new(factory) }
        end

        production(:item) do
          clause('atom') { |factory| factory }
          clause('LEFT_PAREN .choice RIGHT_PAREN') do |factories|
            ChoiceFactory.new(factories)
          end
        end

        production(:choice) do
          clause('.atom+ OR .atom+') do |left_atoms, right_atoms|
            [maybe_concatenate(left_atoms), maybe_concatenate(right_atoms)]
          end
          clause('.choice OR .atom+') do |choices, right_atoms|
            choices + [maybe_concatenate(right_atoms)]
          end
        end

        production(:atom) do
          clause('option') { |option| option }
          clause('WORD') { |word| TextTransitionFactory.new(word) }
          clause('OPT_VAR') { |_| OptionTransitionFactory.new }
          clause('VAR') do |var_name|
            VariableTransitionFactory.new(matcher_for_variable(var_name))
          end
        end

        production(:option, 'OPTION') do |opt_name|
          TextTransitionFactory.new(opt_name)
        end

        finalize
      end
    end
  end
end
