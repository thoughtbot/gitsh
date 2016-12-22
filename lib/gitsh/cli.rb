require 'optparse'
require 'gitsh/environment'
require 'gitsh/exit_statuses'
require 'gitsh/interactive_runner'
require 'gitsh/program_name'
require 'gitsh/script_runner'
require 'gitsh/version'

module Gitsh
  class CLI
    def initialize(opts={})
      $PROGRAM_NAME = PROGRAM_NAME

      @env = opts.fetch(:env, Environment.new)
      @unparsed_args = opts.fetch(:args, ARGV).clone
      @interactive_runner = opts.fetch(
        :interactive_runner,
        InteractiveRunner.new(env: @env)
      )
      @script_runner = opts.fetch(:script_runner) { ScriptRunner.new(env: @env) }
    end

    def run
      parse_arguments
      if unparsed_args.any?
        exit_with_usage_message
      end
      ensure_executable_git
      if script_file
        run_script
      else
        interactive_runner.run
      end
    end

    private

    attr_reader :env, :unparsed_args, :script_file_argument,
      :interactive_runner, :script_runner

    def run_script
      script_runner.run(script_file)
    rescue NoInputError => error
      env.puts_error("gitsh: #{error.message}")
      exit EX_NOINPUT
    end

    def script_file
      if script_file_argument
        script_file_argument
      elsif !env.tty?
        ScriptRunner::STDIN_PLACEHOLDER
      end
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
      @script_file_argument = unparsed_args.pop
    rescue OptionParser::InvalidOption => err
      unparsed_args.concat(err.args)
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
