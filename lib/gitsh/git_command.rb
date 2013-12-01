require 'shellwords'

module Gitsh
  class GitCommand
    def initialize(env, command, args=[])
      @env = env
      @sub_command = command
      @args = args
    end

    def execute
      git = Shellwords.split(env.git_command)
      cmd = [git, sub_command, args].flatten
      pid = Process.spawn(*cmd, out: env.output_stream, err: env.error_stream)
      Process.wait(pid)
    end

    private

    attr_reader :env, :sub_command, :args
  end
end
