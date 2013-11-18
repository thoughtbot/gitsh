require 'readline'
require 'gitsh/git_driver'
require 'gitsh/prompter'
require 'gitsh/completer'

module Gitsh
  class CLI
    def initialize(output=$stdout, error=$stderr, readline=Readline)
      @output = output
      @error = error
      @readline = readline
    end

    def run
      readline.completion_append_character = nil
      readline.completion_proc = Completer.new(readline)

      while command = read_command
        git_driver.execute(command)
      end

      output.print "\n"
    end

    private

    attr_reader :output, :error, :readline

    def read_command
      command = readline.readline(prompt, true)
      command != 'exit' && command
    end

    def git_driver
      @git_driver ||= GitDriver.new(output, error)
    end

    def prompt
      prompter.prompt
    end

    def prompter
      @prompter ||= Prompter.new(color: color_support?)
    end

    def color_support?
      output, error, exit_status = Open3.capture3('tput colors')
      exit_status.success? && output.chomp.to_i > 0
    end
  end
end
