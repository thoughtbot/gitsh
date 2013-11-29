require 'shellwords'

module Gitsh
  class GitDriver
    DEFAULT_GIT_COMMAND = '/usr/bin/env git'.freeze

    def initialize(output, error, git_command=nil)
      @output = output
      @error = error
      @git_command = Shellwords.split(git_command || DEFAULT_GIT_COMMAND)
    end

    def execute(command)
      cmd = git_command + Shellwords.split(command)
      pid = Process.spawn(*cmd, out: output, err: error)
      Process.wait(pid)
    end

    private

    attr_reader :output, :error, :git_command
  end
end
