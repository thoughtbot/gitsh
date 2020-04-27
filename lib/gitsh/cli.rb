require 'optparse'
require 'gitsh/exit_statuses'
require 'gitsh/input_strategies/file'
require 'gitsh/input_strategies/interactive'
require 'gitsh/interpreter'
require 'gitsh/registry'
require 'gitsh/version'

module Gitsh
  class CLI
    extend Registry::Client
    use_registry_for :env

    def initialize(args)
      @unparsed_args = args.clone
    end

    def run
      parse_arguments
      ensure_executable_git
      interpreter.run
    rescue NoInputError => error
      env.puts_error("gitsh: #{error.message}")
      exit EX_NOINPUT
    end

    private

    attr_reader :unparsed_args, :script_file_argument

    def interpreter
      Interpreter.new(env: env, input_strategy: input_strategy)
    end

    def input_strategy
      if script_file
        InputStrategies::File.new(path: script_file)
      else
        InputStrategies::Interactive.new
      end
    end

    def script_file
      if script_file_argument
        script_file_argument
      elsif !env.tty?
        InputStrategies::File::STDIN_PLACEHOLDER
      end
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
      @script_file_argument = unparsed_args.pop

      if unparsed_args.any?
        exit_with_usage_message
      end
    rescue OptionParser::InvalidOption
      exit_with_usage_message
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = 'usage: gitsh [--version] [-h | --help] [--git PATH] [script]'

        opts.on('--git PATH', 'Use the specified git command') do |git_command|
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

    def ensure_executable_git
      IO.popen(env.git_command).close
    rescue Errno::ENOENT
      env.puts_error(
        "gitsh: #{env.git_command}: No such file or directory\nEnsure git is "\
        'on your PATH, or specify the path to git using the --git option',
      )
      exit EX_UNAVAILABLE
    rescue Errno::EACCES
      env.puts_error(
        "gitsh: #{env.git_command}: Permission denied\nEnsure git is "\
        'executable',
      )
      exit EX_UNAVAILABLE
    end
  end
end
