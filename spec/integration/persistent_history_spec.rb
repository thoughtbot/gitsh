require 'spec_helper'

describe 'Gitsh history' do
  it 'is persisted between sessions' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('foobarbaz')
      expect(gitsh).to output_error(/'foobarbaz' is not a git command/)
    end

    GitshRunner.interactive do |gitsh|
      gitsh.type(GitshRunner::UP_ARROW * 2)
      expect(gitsh).to output_error(/'foobarbaz' is not a git command/)
    end
  end

  it 'uses the gitsh.historyFile setting' do
    with_a_temporary_home_directory do
      settings = { 'gitsh.historyFile' => '~/my_gitsh_history' }
      GitshRunner.interactive(settings: settings) do |gitsh|
        gitsh.type('foobarbaz')
      end

      expect(File.read("#{ENV['HOME']}/my_gitsh_history")).to match(/foobarbaz/)
    end
  end
end
