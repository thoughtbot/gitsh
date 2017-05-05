require 'rltk'
require 'gitsh/tab_completion/dsl/rule_set_factory'
require 'gitsh/tab_completion/dsl/rule_factory'
require 'gitsh/tab_completion/dsl/concatenation_factory'
require 'gitsh/tab_completion/dsl/text_transition_factory'
require 'gitsh/tab_completion/dsl/star_operation_factory'
require 'gitsh/tab_completion/dsl/plus_operation_factory'
require 'gitsh/tab_completion/dsl/maybe_operation_factory'
require 'gitsh/tab_completion/dsl/variable_transition_factory'

module Gitsh
  module TabCompletion
    module DSL
      class Parser < RLTK::Parser
        class Environment < RLTK::Parser::Environment
          def maybe_concatenate(factories)
            if factories.length > 1
              ConcatenationFactory.new(factories)
            else
              factories.first
            end
          end
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
          clause('.rule BLANK .rule') { |rule1, rule2| [rule1, rule2] }
          clause('.rules BLANK .rule') { |rules, rule| rules + [rule] }
        end

        production(:rule) do
          clause('command_format') { |factory| RuleFactory.new(factory, []) }
          clause('command_format option+') do |factory, options|
            RuleFactory.new(factory, options)
          end
        end

        production(:command_format, 'term+') do |factories|
          maybe_concatenate(factories)
        end

        production(:option) do
          clause('INDENT .OPTION') { |name| Option.new(name) }
          clause('INDENT .OPTION .term') do |name, argument_factory|
            Option.new(name, argument_factory)
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
          clause('WORD') { |word| TextTransitionFactory.new(word) }
          clause('VAR') { |var_name| VariableTransitionFactory.new(var_name) }
          #FIXME: Replace VariableTransitionFactory with VARIABLES.fetch(var_name).new
          clause('OPTION') { |opt_name| TextTransitionFactory.new(opt_name) }
        end

        finalize
      end

      class ChoiceFactory
        attr_reader :choices

        def initialize(choices)
          @choices = choices
        end

        #FIXME: Move out of this file
        #FIXME: Add a #build method
      end

      class Option
        attr_reader :name

        def initialize(name, argument_factory = nil)
          @name = name
          @argument_factory = argument_factory
        end

        #FIXME: Move out of this file
        #FIXME: Some way of working with the argument

        private

        attr_reader :argument_factory
      end
    end
  end
end
