require 'spec_helper'

describe 'Colors as determinined from the environemnt' do
  include Color

  it 'is uncolored for old terminals' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to prompt_with 'uninitialized!! '
    end
  end

  it 'is colored for color xterm' do
    GitshRunner.interactive('TERM' => 'xterm-color') do |gitsh|
      expect(gitsh).to prompt_with "uninitialized#{red_background}!!#{clear} "
    end
  end
end
