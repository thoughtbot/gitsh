require 'readline'
require 'gitsh/git_driver'

module Gitsh
  class CLI
    def initialize(output=$stdout, error=$stderr, readline=Readline)
      @output = output
      @error = error
      @readline = readline
    end

    def run
      while command = read_command
        git_driver.execute(command)
      end
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
      '>'
    end
  end
end
