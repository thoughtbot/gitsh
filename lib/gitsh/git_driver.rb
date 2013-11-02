require 'open3'

module Gitsh
  class GitDriver
    def initialize(output, error)
      @output = output
      @error = error
    end

    def execute(command)
      Open3.popen3("/usr/bin/env git #{command}") do |cmd_in, cmd_out, cmd_err, cmd_exit|
        IO.copy_stream(cmd_out, output)
        IO.copy_stream(cmd_err, error)
      end
    end

    private

    attr_reader :output, :error
  end
end
