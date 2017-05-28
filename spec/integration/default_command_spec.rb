require 'spec_helper'

describe 'Entering no command' do
  it 'runs `git status`' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('')

      expect(gitsh).to output(/nothing to commit/)
    end
  end

  it 'runs `git status` ignoring white space' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('    ')

      expect(gitsh).to output(/nothing to commit/)
    end
  end

  it 'can be overriden using a git-config variable' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('config --local gitsh.defaultCommand "show HEAD"')
      gitsh.type('commit --allow-empty -m First')
      gitsh.type('')

      expect(gitsh).to output(/First/)

      gitsh.type('commit --allow-empty -m Second')
      gitsh.type('')

      expect(gitsh).to output(/Second/)
    end
  end
end
