require 'readline'
require 'gitsh/completer'
require 'gitsh/error'
require 'gitsh/history'
require 'gitsh/interpreter'
require 'gitsh/prompter'
require 'gitsh/readline_history_filter'
require 'gitsh/script_runner'
require 'gitsh/terminal'

module Gitsh
  class InteractiveRunner
    BLANK_LINE_REGEX = /^\s*$/

    def initialize(opts)
      @readline = opts.fetch(:readline) { ReadlineHistoryFilter.new(Readline) }
      @env = opts[:env]
      @history = opts.fetch(:history) { History.new(@env, @readline) }
      @interpreter = opts.fetch(:interpreter) { Interpreter.new(@env) }
      @terminal = opts.fetch(:terminal) { Terminal.instance }
      @script_runner = opts.fetch(:script_runner) { ScriptRunner.new(env: @env) }
    end

    def run
      history.load
      setup_readline
      handle_window_resize
      greet_user
      load_gitshrc
      interactive_loop
    ensure
      history.save
    end

    private

    attr_reader :history, :readline, :env, :interpreter, :terminal,
      :script_runner

    def setup_readline
      readline.completion_append_character = nil
      readline.completion_proc = Completer.new(readline, env)
    end

    def handle_window_resize
      Signal.trap('WINCH') do
        begin
          readline.set_screen_size(*terminal.size)
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
      command = readline.readline(prompt, true)
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
