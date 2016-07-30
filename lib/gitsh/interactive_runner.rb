require 'gitsh/completer'
require 'gitsh/completion_escaper'
require 'gitsh/error'
require 'gitsh/history'
require 'gitsh/interpreter'
require 'gitsh/line_editor'
require 'gitsh/line_editor_history_filter'
require 'gitsh/prompter'
require 'gitsh/quote_detector'
require 'gitsh/script_runner'
require 'gitsh/terminal'

module Gitsh
  class InteractiveRunner
    BLANK_LINE_REGEX = /^\s*$/

    def initialize(opts)
      @line_editor = opts.fetch(:line_editor) do
        LineEditorHistoryFilter.new(Gitsh::LineEditor)
      end
      @env = opts[:env]
      @history = opts.fetch(:history) { History.new(@env, @line_editor) }
      @interpreter = opts.fetch(:interpreter) { Interpreter.new(@env) }
      @terminal = opts.fetch(:terminal) { Terminal.instance }
      @script_runner = opts.fetch(:script_runner) { ScriptRunner.new(env: @env) }
    end

    def run
      history.load
      setup_line_editor
      handle_window_resize
      greet_user
      load_gitshrc
      interactive_loop
    ensure
      history.save
    end

    private

    attr_reader :history, :line_editor, :env, :interpreter, :terminal,
      :script_runner

    def setup_line_editor
      line_editor.completion_proc = CompletionEscaper.new(
        Completer.new(line_editor, env),
        line_editor: line_editor,
      )
      line_editor.completer_quote_characters = '\'"'
      line_editor.completer_word_break_characters = ' &|;'
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
      script_runner.run(gitshrc_path)
    rescue NoInputError
    end

    def gitshrc_path
      "#{ENV['HOME']}/.gitshrc"
    end

    def interactive_loop
      while command = read_command
        interpreter.execute(command)
      end
      env.print "\n"
    rescue Interrupt
      env.print "\n"
      retry
    end

    def read_command
      command = line_editor.readline(prompt, true)
      if command && command.match(BLANK_LINE_REGEX)
        env.fetch('gitsh.defaultCommand') { 'status' }
      else
        command
      end
    end

    def prompt
      prompter.prompt
    end

    def prompter
      @prompter ||= Prompter.new(env: env, color: terminal.color_support?)
    end
  end
end
