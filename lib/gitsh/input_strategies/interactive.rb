require 'gitsh/error'
require 'gitsh/file_runner'
require 'gitsh/history'
require 'gitsh/line_editor'
require 'gitsh/line_editor_history_filter'
require 'gitsh/prompter'
require 'gitsh/quote_detector'
require 'gitsh/tab_completion/facade'
require 'gitsh/terminal'

module Gitsh
  module InputStrategies
    class Interactive
      BLANK_LINE_REGEX = /^\s*$/
      CONTINUATION_PROMPT = '> '.freeze

      def initialize(opts)
        @line_editor = opts.fetch(:line_editor) do
          LineEditorHistoryFilter.new(Gitsh::LineEditor)
        end
        @env = opts[:env]
        @history = opts.fetch(:history) { History.new(@env, @line_editor) }
        @terminal = opts.fetch(:terminal) { Terminal.instance }
      end

      def setup
        history.load
        setup_line_editor
        handle_window_resize
        greet_user
        load_gitshrc
      end

      def teardown
        env.print "\n"
        history.save
      end

      def read_command
        command = line_editor.readline(prompt, true)
        if command && command.match(BLANK_LINE_REGEX)
          env.fetch('gitsh.defaultCommand') { 'status' }
        else
          command
        end
      rescue Interrupt
        env.print "\n"
        retry
      end

      def read_continuation
        input = begin
          line_editor.readline(CONTINUATION_PROMPT, true)
        rescue Interrupt
          nil
        end

        if input.nil?
          env.print "\n"
        end

        input
      end

      def handle_parse_error(message)
        env.puts_error("gitsh: #{message}")
      end

      private

      attr_reader :history, :line_editor, :env, :terminal

      def setup_line_editor
        line_editor.completion_proc = TabCompletion::Facade.new(line_editor, env)
        line_editor.completer_quote_characters = %('")
        line_editor.completer_word_break_characters = ' &|;('
        line_editor.quoting_detection_proc = QuoteDetector.new
      end

      def handle_window_resize
        Signal.trap('WINCH') do
          begin
            line_editor.set_screen_size(*terminal.size)
          rescue Terminal::UnknownSizeError
          end
        end
      end

      def greet_user
        if greeting_enabled?
          env.puts "gitsh #{Gitsh::VERSION}\nType :exit to exit"
        end
      end

      def greeting_enabled?
        env.fetch('gitsh.noGreeting') { 'false' } != 'true'
      end

      def load_gitshrc
        FileRunner.run(env: env, path: gitshrc_path)
      rescue ParseError => e
        env.puts_error "gitsh: #{e.message}"
      rescue NoInputError
      end

      def gitshrc_path
        "#{ENV['HOME']}/.gitshrc"
      end

      def prompt
        prompter.prompt
      end

      def prompter
        @prompter ||= Prompter.new(env: env, color: terminal.color_support?)
      end
    end
  end
end
