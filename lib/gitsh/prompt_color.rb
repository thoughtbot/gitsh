require 'gitsh/colors'

module Gitsh
  class PromptColor
    def initialize(env)
      @env = env
    end

    def status_color
      if !env.repo_initialized?
        env.repo_config_color('gitsh.color.uninitialized', 'normal red')
      elsif env.repo_has_untracked_files?
        env.repo_config_color('gitsh.color.untracked', 'red')
      elsif env.repo_has_modified_files?
        env.repo_config_color('gitsh.color.modified', 'orange')
      else
        env.repo_config_color('gitsh.color.default', 'blue')
      end
    end

    private

    attr_reader :env
  end
end
