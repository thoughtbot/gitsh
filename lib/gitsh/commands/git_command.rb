require 'shellwords'
require 'gitsh/commands/shell_command'

module Gitsh::Commands
  class GitCommand < ShellCommand
    private

    def command_with_arguments
      [git_command, config_arguments, command, args].flatten
    end

    def git_command
      Shellwords.split(env.git_command)
    end

    def config_arguments
      env.config_variables.map { |k, v| ['-c', "#{k}=#{v}"] }
    end
  end
end
