module Gitsh
  class GitCommandList
    def initialize(env)
      @env = env
    end

    def to_a
      git_output('help -a').
        lines.
        select { |line| line =~ /^  [a-z]/ }.
        map { |line| line.split(/\s+/) }.
        flatten.
        reject { |cmd| cmd.empty? || cmd =~ /--/ }.
        sort
    end

    private

    attr_accessor :env

    def git_output(command)
      Open3.capture3(git_command(command)).first.chomp
    end

    def git_command(sub_command)
      "#{env.git_command} #{sub_command}"
    end
  end
end
