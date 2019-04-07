require 'gitsh/environment'
require 'gitsh/registry'

module Registry
  def register_env(attrs = {})
    default_atts = {
      git_command: fake_git_path,
      tty?: true,
      puts_error: nil,
    }
    Gitsh::Registry[:env] = instance_double(
      Gitsh::Environment,
      default_atts.merge(attrs),
    )
  end
end

RSpec.configure do |config|
  config.include Registry
  config.before { Gitsh::Registry.clear }
end
