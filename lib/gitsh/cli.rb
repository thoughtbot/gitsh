require 'readline'
require 'optparse'
require 'gitsh/completer'
require 'gitsh/environment'
require 'gitsh/history'
require 'gitsh/interpreter'
require 'gitsh/prompter'
require 'gitsh/version'

module Gitsh
  class CLI
    EX_OK = 0
    EX_USAGE = 64

    def initialize(opts={})
      interpreter_factory = opts.fetch(:interpreter_factory, Interpreter)

      @env = opts.fetch(:env, Environment.new)
      @interpreter = interpreter_factory.new(@env)
      @readline = opts.fetch(:readline, Readline)
      @unparsed_args = opts.fetch(:args, ARGV).clone
      @history = opts.fetch(:history, History.new(@env, @readline))
    end

    def run
      parse_arguments
      if unparsed_args.any?
        exit_with_usage_message
      else
        run_interactive
      end
    end

    private

    attr_reader :env, :readline, :unparsed_args, :interpreter, :history

    def run_interactive
      history.load
      setup_readline
      greet_user
      interactive_loop
    ensure
      history.save
    end

    def setup_readline
      readline.completion_append_character = nil
      readline.completion_proc = Completer.new(readline, env)
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
      if command && command.empty?
        env.fetch('gitsh.defaultCommand', 'status')
      else
        command
      end
    end

    def prompt
      prompter.prompt
    end

    def prompter
      @prompter ||= Prompter.new(env: env, color: color_support?)
    end

    def color_support?
      output, error, exit_status = Open3.capture3('tput colors')
      exit_status.success? && output.chomp.to_i > 0
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
    rescue OptionParser::InvalidOption => err
      unparsed_args.concat(err.args)
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = 'usage: gitsh [--version] [-h | --help] [--git PATH]'

        opts.on('--git [COMMAND]', 'Use the specified git command') do |git_command|
          env.git_command = git_command
        end

        opts.on_tail('--version', 'Display the version and exit') do
          env.puts VERSION
          exit EX_OK
        end

        opts.on_tail('--help', '-h', 'Display this help message and exit') do
          env.puts opts
          exit EX_OK
        end
      end
    end

    def greet_user
      unless env['gitsh.noGreeting'] == 'true'
        env.puts "gitsh #{Gitsh::VERSION}\nType :exit to exit"
      end
    end
  end
end
