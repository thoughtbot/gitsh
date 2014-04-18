require 'readline'
require 'gitsh/completer'
require 'gitsh/history'
require 'gitsh/interpreter'
require 'gitsh/prompter'
require 'gitsh/readline_blank_filter'
require 'gitsh/term_info'

module Gitsh
  class InteractiveRunner
    BLANK_LINE_REGEX = /^\s*$/

    def initialize(opts)
      @readline = opts.fetch(:readline) { ReadlineBlankFilter.new(Readline) }
      @env = opts[:env]
      @history = opts.fetch(:history, History.new(@env, @readline))
      @interpreter = opts.fetch(:interpreter, Interpreter.new(@env))
      @term_info = opts.fetch(:term_info) { TermInfo.instance }
    end

    def run
      history.load
      setup_readline
      handle_window_resize
      greet_user
      interactive_loop
    ensure
      history.save
    end

    private

    attr_reader :history, :readline, :env, :interpreter, :term_info

    def setup_readline
      readline.completion_append_character = nil
      readline.completion_proc = Completer.new(readline, env)
    end

    def handle_window_resize
      Signal.trap('WINCH') do
        readline.set_screen_size(term_info.lines, term_info.cols)
      end
    end

    def greet_user
      unless env['gitsh.noGreeting'] == 'true'
        env.puts "gitsh #{Gitsh::VERSION}\nType :exit to exit"
      end
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
        env.fetch('gitsh.defaultCommand', 'status')
      else
        command
      end
    end

    def prompt
      prompter.prompt
    end

    def prompter
      @prompter ||= Prompter.new(env: env, color: term_info.color_support?)
    end
  end
end
