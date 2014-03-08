module Gitsh
  class ShellCommand
    def initialize(env, command, args = [])
      @env = env
      @command = command
      @args = args
    end

    def execute
      pid = Process.spawn(
        *command_with_arguments,
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
      Process.wait(pid)
      $? && $?.success?
    rescue SystemCallError => e
      env.puts_error e.message
      false
    end

    private

    attr_reader :env, :command, :args

    def command_with_arguments
      [command, args].flatten
    end
  end
end
