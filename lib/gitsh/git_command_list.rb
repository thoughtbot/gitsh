module Gitsh
  class GitCommandList
    def initialize(env)
      @env = env
    end

    def to_a
      try_using(commands_from_list_cmds) do
        try_using(commands_from_help('help -a --no-verbose')) do
          try_using(commands_from_help('help -a'))
        end
      end
    end

    private

    attr_accessor :env

    def try_using(result, default: [])
      if result && result.any?
        result
      elsif block_given?
        yield
      else
        default
      end
    end

    def commands_from_list_cmds
      git_output('--list-cmds=main,nohelpers').sort
    end

    def commands_from_help(command)
      git_output(command).
        select { |line| line =~ /^  [a-z]/ }.
        map { |line| line.split(/\s+/) }.
        flatten.
        reject { |cmd| cmd.empty? || cmd =~ /--/ }.
        sort
    end

    def git_output(command)
      output, _, status = Open3.capture3(git_command(command))

      if status.success?
        output.chomp.lines.map(&:chomp)
      else
        []
      end
    end

    def git_command(sub_command)
      "#{env.git_command} #{sub_command}"
    end
  end
end
