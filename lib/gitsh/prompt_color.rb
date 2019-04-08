require 'gitsh/colors'
require 'gitsh/registry'

module Gitsh
  class PromptColor
    extend Registry::Client
    use_registry_for :env, :repo

    def status_color(status)
      if !status.initialized?
        color_setting('gitsh.color.uninitialized', default: 'normal red')
      elsif status.has_untracked_files?
        color_setting('gitsh.color.untracked', default: 'red')
      elsif status.has_modified_files?
        color_setting('gitsh.color.modified', default: 'yellow')
      else
        color_setting('gitsh.color.default', default: 'blue')
      end
    end

    private

    def color_setting(setting_name, default:)
      color_name = env.fetch(setting_name) { default }
      repo.color(color_name)
    end
  end
end
