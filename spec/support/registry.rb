require 'gitsh/environment'
require 'gitsh/registry'

module Registry
  def register_env(attrs = {})
    default_atts = {
      config_directory: File.expand_path('../../etc', __FILE__),
      git_command: fake_git_path,
      print: nil,
      puts: nil,
      puts_error: nil,
      tty?: true,
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
