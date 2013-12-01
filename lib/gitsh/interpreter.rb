require 'gitsh/git_driver'

module Gitsh
  class Interpreter
    def initialize(env, options={})
      driver_factory = options.fetch(:driver_factory, GitDriver)

      @env = env
      @git_driver = driver_factory.new(env)
    end

    def execute(command)
      git_driver.execute(command)
    end

    private

    attr_reader :env, :git_driver
  end
end
