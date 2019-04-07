require 'gitsh/tab_completion/alias_expander'
require 'gitsh/tab_completion/automaton_factory'
require 'gitsh/tab_completion/command_completer'
require 'gitsh/tab_completion/context'
require 'gitsh/tab_completion/escaper'
require 'gitsh/tab_completion/variable_completer'
require 'gitsh/registry'

module Gitsh
  module TabCompletion
    class Facade
      def initialize(line_editor)
        @line_editor = line_editor
        @automaton = AutomatonFactory.build(env)
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

      attr_reader :line_editor, :automaton

      def command_completions(context, input)
        CommandCompleter.new(
          line_editor,
          AliasExpander.new(context.prior_words, env).call,
          input,
          automaton,
          escaper,
        ).call
      end

      def variable_completions(input)
        VariableCompleter.new(line_editor, input, env).call
      end

      def escaper
        @escaper ||= Escaper.new(line_editor)
      end

      def env
        Registry.env
      end
    end
  end
end
