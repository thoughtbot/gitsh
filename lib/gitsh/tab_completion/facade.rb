require 'gitsh/registry'
require 'gitsh/tab_completion/alias_expander'
require 'gitsh/tab_completion/automaton_factory'
require 'gitsh/tab_completion/command_completer'
require 'gitsh/tab_completion/context'
require 'gitsh/tab_completion/escaper'
require 'gitsh/tab_completion/variable_completer'

module Gitsh
  module TabCompletion
    class Facade
      extend Registry::Client
      use_registry_for :line_editor

      def initialize
        @automaton = AutomatonFactory.build
      end

      def call(input)
        context = Context.new(line_editor.line_buffer)
        if context.completing_variable?
          variable_completions(input)
        else
          command_completions(context, input)
        end
      end

      private

      attr_reader :automaton

      def command_completions(context, input)
        CommandCompleter.new(
          AliasExpander.new(context.prior_words).call,
          input,
          automaton,
          escaper,
        ).call
      end

      def variable_completions(input)
        VariableCompleter.new(input).call
      end

      def escaper
        @escaper ||= Escaper.new
      end
    end
  end
end
