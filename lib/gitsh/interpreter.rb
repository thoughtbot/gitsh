require 'gitsh/git_command'

module Gitsh
  class Interpreter
    def initialize(env, options={})
      @env = env
      @git_command_factory = options.fetch(:git_command_factory, GitCommand)
    end

    def execute(input)
      build_command(input).execute(env)
    end

    private

    attr_reader :env, :git_command_factory

    def build_command(input)
      git_command_factory.new(input)
    end
  end
end
