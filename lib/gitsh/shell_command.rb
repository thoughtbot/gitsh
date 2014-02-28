module Gitsh
  class ShellCommand
    def initialize(env, command, args = [])
      @env = env
      @command = command
      @args = args
    end

    def execute
      cmd = [command, args].flatten
      pid = Process.spawn(
        *cmd,
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
      Process.wait(pid)
      $? && $?.success?
    end

    private

    attr_reader :env, :command, :args
  end
end
