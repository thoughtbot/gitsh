require 'spec_helper'

describe 'Entering no command' do
  it 'runs `git status`' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('')

      expect(gitsh).to output /nothing to commit/
    end
  end
end
