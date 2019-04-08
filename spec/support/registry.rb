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
