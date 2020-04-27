require 'gitsh/registry'

module Gitsh
  class History
    extend Registry::Client
    use_registry_for :env, :line_editor

    DEFAULT_HISTORY_FILE = "#{Dir.home}/.gitsh_history"
    DEFAULT_HISTORY_SIZE = 500

    def self.load
      new.load
    end

    def self.save
      new.save
    end

    def load
      File.read(history_file_path).lines.each do |command|
        line_editor::HISTORY << command.chomp
      end
    rescue Errno::ENOENT
    end

    def save
      File.open(history_file_path, 'w') do |file|
        line_editor::HISTORY.to_a.last(history_size).each do |command|
          file << "#{command}\n"
        end
      end
    end

    private

    def history_file_exists?
      File.exist?(history_file_path)
    end

    def history_file_path
      File.expand_path(env.fetch('gitsh.historyFile') { DEFAULT_HISTORY_FILE })
    end

    def history_size
      env.fetch('gitsh.historySize') { DEFAULT_HISTORY_SIZE }.to_i
    end
  end
end
