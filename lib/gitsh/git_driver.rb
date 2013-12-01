require 'shellwords'

module Gitsh
  class GitDriver
    def initialize(env)
      @env = env
    end

    def execute(command)
      cmd = Shellwords.split(env.git_command) + Shellwords.split(command)
      pid = Process.spawn(*cmd, out: env.output_stream, err: env.error_stream)
      Process.wait(pid)
    end

    private

    attr_reader :env
  end
end
