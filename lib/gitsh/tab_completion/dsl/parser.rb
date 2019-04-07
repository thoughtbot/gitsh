require 'rltk'
require 'gitsh/tab_completion/dsl/choice_factory'
require 'gitsh/tab_completion/dsl/concatenation_factory'
require 'gitsh/tab_completion/dsl/fallback_transition_factory'
require 'gitsh/tab_completion/dsl/parse_error'
require 'gitsh/tab_completion/dsl/maybe_operation_factory'
require 'gitsh/tab_completion/dsl/null_factory'
require 'gitsh/tab_completion/dsl/option_transition_factory'
require 'gitsh/tab_completion/dsl/plus_operation_factory'
require 'gitsh/tab_completion/dsl/rule_factory'
require 'gitsh/tab_completion/dsl/rule_set_factory'
require 'gitsh/tab_completion/dsl/star_operation_factory'
require 'gitsh/tab_completion/dsl/text_transition_factory'
require 'gitsh/tab_completion/dsl/variable_transition_factory'
require 'gitsh/tab_completion/matchers/anything_matcher'
require 'gitsh/tab_completion/matchers/branch_matcher'
require 'gitsh/tab_completion/matchers/command_matcher'
require 'gitsh/tab_completion/matchers/path_matcher'
require 'gitsh/tab_completion/matchers/remote_matcher'
require 'gitsh/tab_completion/matchers/revision_matcher'
require 'gitsh/tab_completion/matchers/tag_matcher'

module Gitsh
  module TabCompletion
    module DSL
      class Parser < RLTK::Parser
        VARIABLE_TO_MATCHER_CLASS = {
          'anything' => Matchers::AnythingMatcher,
          'branch' => Matchers::BranchMatcher,
          'command' => Matchers::CommandMatcher,
          'path' => Matchers::PathMatcher,
          'remote' => Matchers::RemoteMatcher,
          'revision' => Matchers::RevisionMatcher,
          'tag' => Matchers::TagMatcher,
        }.freeze

        MODIFER_TO_TRANSITION_CLASS = {
          'fallback' => FallbackTransitionFactory,
        }.freeze

        class Environment < RLTK::Parser::Environment
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

          def transition_factory_for_modifier(modifier_name)
            MODIFER_TO_TRANSITION_CLASS.fetch(modifier_name)
          end

          private

          def build_matcher(var_name)
            VARIABLE_TO_MATCHER_CLASS.fetch(var_name).new
          rescue KeyError
            raise ParseError.new(
              'Invalid',
              RLTK::Token.new(:VAR, var_name, pos(0)),
            )
          end
        end

        def self.parse(tokens, opts = {})
          super
        rescue RLTK::NotInLanguage => error
          raise ParseError.new('Unexpected', error.current)
        end

        production(:rule_set) do
          clause('BLANK* .rules BLANK*') do |rule_factories|
            RuleSetFactory.new(rule_factories)
          end
          clause('BLANK*') do |_|
            RuleSetFactory.new([])
          end
        end

        production(:rules) do
          clause('.rule') { |rule| [rule] }
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

        production(:command_format, 'command_term+') do |factories|
          maybe_concatenate(factories)
        end

        production(:opt_var_value) do
          clause('INDENT .option') { |option| option }
          clause('INDENT .option .opt_term+') do |option, argument_factories|
            ConcatenationFactory.new([option] + argument_factories)
          end
        end

        [:command, :opt].each do |prefix|
          term = "#{prefix}_term"
          item = "#{prefix}_item"
          choice = "#{prefix}_choice"
          atom = "#{prefix}_atom"

          production(term) do
            clause(item) { |factory| factory }
            clause(".#{item} STAR") do |factory|
              StarOperationFactory.new(factory)
            end
            clause(".#{item} PLUS") do |factory|
              PlusOperationFactory.new(factory)
            end
            clause(".#{item} MAYBE") do |factory|
              MaybeOperationFactory.new(factory)
            end
          end

          production(item) do
            clause(atom) { |factory| factory }
            clause("LEFT_PAREN .#{choice} RIGHT_PAREN") do |factories|
              ChoiceFactory.new(factories)
            end
          end

          production(choice) do
            clause(".#{atom}+ OR .#{atom}+") do |left, right|
              [maybe_concatenate(left), maybe_concatenate(right)]
            end
            clause(".#{choice} OR .#{atom}+") do |left, right|
              left + [maybe_concatenate(right)]
            end
          end
        end

        production(:command_atom) do
          clause('opt_atom') { |factory| factory }
          clause('option') { |option| option }
          clause('OPT_VAR') { |_| OptionTransitionFactory.new }
        end

        production(:opt_atom) do
          clause('WORD') { |word| TextTransitionFactory.new(word) }
          clause('var') { |var| var }
        end

        production(:option, 'OPTION') do |opt_name|
          TextTransitionFactory.new(opt_name)
        end

        production(:var) do
          clause('VAR') do |var_name|
            VariableTransitionFactory.new(matcher_for_variable(var_name))
          end

          clause('MODIFIER VAR') do |modifier_name, var_name|
            matcher = matcher_for_variable(var_name)
            transition_factory_for_modifier(modifier_name).new(matcher)
          end
        end

        finalize
      end
    end
  end
end
