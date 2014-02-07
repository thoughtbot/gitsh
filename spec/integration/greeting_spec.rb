require 'spec_helper'

describe 'Displaying a welcome message when gitsh starts' do
  it 'helps users understand what is going on' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to output /gitsh #{Gitsh::VERSION}\nType :exit to exit/
    end
  end

  it 'can be disabled' do
    settings = { 'gitsh.noGreeting' => 'true' }
    GitshRunner.interactive(settings: settings) do |gitsh|
      expect(gitsh).to output_nothing
    end
  end
end
