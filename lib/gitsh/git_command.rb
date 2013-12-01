require 'shellwords'

module Gitsh
  class GitCommand
    def initialize(command)
      @command = command
    end

    def execute(env)
      cmd = Shellwords.split(env.git_command) + Shellwords.split(command)
      pid = Process.spawn(*cmd, out: env.output_stream, err: env.error_stream)
      Process.wait(pid)
    end

    private

    attr_reader :command
  end
end
