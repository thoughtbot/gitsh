require 'spec_helper'

describe 'The gitsh prompt' do
  include Color

  it 'is customised by a git config variable' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      expect(gitsh).to prompt_with 'master@ '
      gitsh.type('config gitsh.prompt "on %b %#"')
      expect(gitsh).to prompt_with 'on master @ '
    end
  end
end
