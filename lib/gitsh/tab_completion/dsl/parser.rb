require 'rltk'

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
          clause('OPTION') { |opt_name| TextTransitionFactory.new(opt_name) }
        end

        finalize
      end

      class RuleSetFactory
        attr_reader :rules

        def initialize(rules)
          @rules = rules
        end
      end

      class RuleFactory
        attr_reader :root, :options

        def initialize(root, options)
          @root = root
          @options = options
        end
      end

      class TextTransitionFactory
        attr_reader :word

        def initialize(word)
          @word = word
        end
      end

      class VariableTransitionFactory
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end

      class ConcatenationFactory
        attr_reader :parts

        def initialize(parts)
          @parts = parts
        end
      end

      class StarOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end
      end

      class PlusOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end
      end

      class MaybeOperationFactory
        attr_reader :child

        def initialize(child)
          @child = child
        end
      end

      class ChoiceFactory
        attr_reader :choices

        def initialize(choices)
          @choices = choices
        end
      end

      class Option
        attr_reader :name

        def initialize(name, argument_factory = nil)
          @name = name
          @argument_factory = argument_factory
        end

        private

        attr_reader :argument_factory
      end
    end
  end
end
