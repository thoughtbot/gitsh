require 'open3'

module Gitsh
  class Terminal
    class UnknownSizeError < StandardError; end

    def self.color_support?
      new.color_support?
    end

    def self.size
      new.size
    end

    def color_support?
      execute('tput colors').to_i > 0
    end

    def size
      size_from_stty || size_from_tput
    end

    private

    def size_from_stty
      size = execute('stty size')
      unless size.nil?
        size.split(/\s+/, 2).map(&:to_i)
      end
    end

    def size_from_tput
      [
        lines_from_tput.to_i,
        cols_from_tput.to_i,
      ]
    end

    def lines_from_tput
      execute('env LINES="" tput lines') ||
        execute('tput lines') ||
        raise(UnknownSizeError, 'Cannot determine terminal size')
    end

    def cols_from_tput
      execute('env COLUMNS="" tput cols') ||
        execute('tput cols') ||
        raise(UnknownSizeError, 'Cannot determine terminal size')
    end

    def execute(command)
      output = IO.popen(command, err: '/dev/null') { |io| io.read }
      if $?.success?
        output.chomp
      end
    end
  end
end
