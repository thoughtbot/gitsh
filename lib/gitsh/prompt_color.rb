require 'gitsh/colors'

module Gitsh
  class PromptColor
    def initialize(env)
      @env = env
    end

    def status_color(status)
      if !status.initialized?
        env.repo_config_color('gitsh.color.uninitialized', 'normal red')
      elsif status.has_untracked_files?
        env.repo_config_color('gitsh.color.untracked', 'red')
      elsif status.has_modified_files?
        env.repo_config_color('gitsh.color.modified', 'yellow')
      else
        env.repo_config_color('gitsh.color.default', 'blue')
      end
    end

    private

    attr_reader :env
  end
end
