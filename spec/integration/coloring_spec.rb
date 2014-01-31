require 'spec_helper'

describe 'Colors as determinined from the environemnt' do
  include Color

  it 'is uncolored for old terminals' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to prompt_with "#{cwd_basename} uninitialized!! "
    end
  end

  it 'is colored for color xterm' do
    GitshRunner.interactive(env: { 'TERM' => 'xterm-color' }) do |gitsh|
      expect(gitsh).to prompt_with(
        "#{cwd_basename} #{red_background}uninitialized!!#{clear} "
      )
    end
  end
end
