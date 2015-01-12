require 'spec_helper'

describe 'The gitsh prompt' do
  it 'defaults to the directory basename and the branch name' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      expect(gitsh).to prompt_with "#{cwd_basename} master@ "
    end
  end

  it 'can be customised with a Git config variable' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('config gitsh.prompt "on %b %#"')

      expect(gitsh).to prompt_with 'on master @ '
    end
  end

  it 'can be customised with a gitsh environment variable' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type(':set gitsh.prompt "%d:%b%#"')

      expect(gitsh).to prompt_with "#{Dir.getwd}:master@ "
    end
  end
end
