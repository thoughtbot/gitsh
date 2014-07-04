module Gitsh
  class History
    DEFAULT_HISTORY_FILE = "#{Dir.home}/.gitsh_history"
    DEFAULT_HISTORY_SIZE = 500

    def initialize(env, line_editor)
      @env = env
      @line_editor = line_editor
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

    attr_reader :env, :line_editor

    def history_file_exists?
      File.exist?(history_file_path)
    end

    def history_file_path
      env.fetch('gitsh.historyFile') { DEFAULT_HISTORY_FILE }
    end

    def history_size
      env.fetch('gitsh.historySize') { DEFAULT_HISTORY_SIZE }.to_i
    end
  end
end
