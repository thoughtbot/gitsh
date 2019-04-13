require 'gitsh/colors'
require 'gitsh/environment'
require 'gitsh/git_repository'
require 'gitsh/line_editor'
require 'gitsh/registry'

module Registry
  def register(entries)
    entries.each do |name, object|
      Gitsh::Registry[name] = object
    end
  end

  def register_env(attrs = {})
    default_attrs = {
      config_directory: File.expand_path('../../etc', __FILE__),
      git_command: fake_git_path,
      print: nil,
      puts: nil,
      puts_error: nil,
      tty?: true,
    }
    env = instance_double(Gitsh::Environment, default_attrs.merge(attrs))
    allow(env).to receive(:fetch).and_yield
    Gitsh::Registry[:env] = env
  end

  def registered_env
    Gitsh::Registry[:env]
  end

  def set_registered_env_value(key, value)
    allow(Gitsh::Registry[:env]).to receive(:fetch).with(key).and_return(value)
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

  def register_line_editor(attrs = {})
    default_attrs = {
      :'completer_quote_characters=' => nil,
      :'completer_word_break_characters=' => nil,
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil,
      :'completion_suppress_quote=' => nil,
      :'quoting_detection_proc=' => nil,
      readline: nil
    }
    line_editor = class_double(Gitsh::LineEditor, default_attrs.merge(attrs))
    line_editor.const_set('HISTORY', [])
    Gitsh::Registry[:line_editor] = line_editor
  end

  def registered_line_editor
    Gitsh::Registry[:line_editor]
  end
end

RSpec.configure do |config|
  config.include Registry
  config.before { Gitsh::Registry.clear }
end
