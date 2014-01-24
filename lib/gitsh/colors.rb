module Gitsh
  module Colors
    CLEAR = "\033[00m"
    BLACK_FG = "\033[00;30m"
    RED_FG = "\033[00;31m"
    GREEN_FG = "\033[00;32m"
    ORANGE_FG = "\033[00;33m"
    BLUE_FG = "\033[00;34m"
    MAGENTA_FG = "\033[00;35m"
    CYAN_FG = "\033[00;36m"
    WHITE_FG = "\033[00;37m"
    RED_BG = "\033[00;41m"

    COLOR_CODE_FORMAT = /\033\[[0-9;]+m/

    def self.strip_color_codes(string_with_colors)
      string_with_colors.gsub(COLOR_CODE_FORMAT, '')
    end
  end
end
