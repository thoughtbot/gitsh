require 'gitsh/colors'

module Color
  def self.included(other)
    other.let(:clear) { Gitsh::Colors::CLEAR }
    other.let(:red_background) { Gitsh::Colors::RED_BG }
    other.let(:red) { Gitsh::Colors::RED_FG }
    other.let(:yellow) { Gitsh::Colors::YELLOW_FG }
    other.let(:cyan) { Gitsh::Colors::CYAN_FG }
    other.let(:blue) { Gitsh::Colors::BLUE_FG }
  end
end
