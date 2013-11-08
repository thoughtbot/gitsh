module Gitsh
  class GitDriver
    def initialize(output, error)
      @output = output
      @error = error
    end

    def execute(command)
      pid = Process.spawn("/usr/bin/env git #{command}", out: output, err: error)
      Process.wait(pid)
    end

    private

    attr_reader :output, :error
  end
end
