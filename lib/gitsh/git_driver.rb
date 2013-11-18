require 'shellwords'

module Gitsh
  class GitDriver
    def initialize(output, error)
      @output = output
      @error = error
    end

    def execute(command)
      cmd = ['/usr/bin/env', 'git', *Shellwords.split(command)]
      pid = Process.spawn(*cmd, out: output, err: error)
      Process.wait(pid)
    end

    private

    attr_reader :output, :error
  end
end
