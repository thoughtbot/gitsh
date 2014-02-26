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
      config_arguments = env.config_variables.map { |k,v| ['-c', "#{k}=#{v}"] }
      prepare_command
      cmd = [git, config_arguments, sub_command, args].flatten
      pid = Process.spawn(*cmd, out: env.output_stream.to_i, err: env.error_stream.to_i)
      Process.wait(pid)
    end

    private

    def prepare_command
      @sub_command = @args.shift if @sub_command == 'git'
    end

    attr_reader :env, :sub_command, :args
  end
end
