module Gitsh
  class History
    DEFAULT_HISTORY_FILE = "#{Dir.home}/.gitsh_history"
    DEFAULT_HISTORY_SIZE = 500

    def initialize(env, readline)
      @env = env
      @readline = readline
    end

    def load
      File.read(history_file_path).lines.each do |command|
        readline::HISTORY << command.chomp
      end
    rescue Errno::ENOENT
    end

    def save
      File.open(history_file_path, 'w') do |file|
        readline::HISTORY.to_a.last(history_size).each do |command|
          file << "#{command}\n"
        end
      end
    end

    private

    attr_reader :env, :readline

    def history_file_exists?
      File.exist?(history_file_path)
    end

    def history_file_path
      env['gitsh.historyFile'] || DEFAULT_HISTORY_FILE
    end

    def history_size
      (env['gitsh.historySize'] || DEFAULT_HISTORY_SIZE).to_i
    end
  end
end
