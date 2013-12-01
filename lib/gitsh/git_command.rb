require 'shellwords'

module Gitsh
  class GitCommand
    def initialize(command, args=[])
      @sub_command = command
      @args = args
    end

    def execute(env)
      git = Shellwords.split(env.git_command)
      cmd = [git, sub_command, args].flatten
      pid = Process.spawn(*cmd, out: env.output_stream, err: env.error_stream)
      Process.wait(pid)
    end

    private

    attr_reader :sub_command, :args
  end
end
