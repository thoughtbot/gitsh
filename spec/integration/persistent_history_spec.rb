require 'spec_helper'

describe 'Gitsh history' do
  it 'is persisted between sessions' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('foobarbaz')
      expect(gitsh).to output_error /'foobarbaz' is not a git command/
    end

    GitshRunner.interactive do |gitsh|
      gitsh.type(GitshRunner::UP_ARROW * 2)
      expect(gitsh).to output_error /'foobarbaz' is not a git command/
    end
  end
end
