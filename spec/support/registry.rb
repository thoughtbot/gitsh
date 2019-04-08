require 'gitsh/colors'
require 'gitsh/environment'
require 'gitsh/git_repository'
require 'gitsh/registry'

module Registry
  def register_env(attrs = {})
    default_attrs = {
      config_directory: File.expand_path('../../etc', __FILE__),
      git_command: fake_git_path,
      print: nil,
      puts: nil,
      puts_error: nil,
      tty?: true,
    }
    Gitsh::Registry[:env] = instance_double(
      Gitsh::Environment,
      default_attrs.merge(attrs),
    )
  end

  def register_repo(attrs = {})
    default_attrs = {
      current_head: 'master',
      color: Gitsh::Colors::RED_FG,
      status: instance_double(
        Gitsh::GitRepository::Status,
        initialized?: true,
        has_untracked_files?: false,
        has_modified_files?: false,
      ),
    }
    Gitsh::Registry[:repo] = instance_double(
      Gitsh::GitRepository,
      default_attrs.merge(attrs),
    )
  end
end

RSpec.configure do |config|
  config.include Registry
  config.before { Gitsh::Registry.clear }
end
