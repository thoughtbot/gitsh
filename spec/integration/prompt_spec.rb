require 'spec_helper'

describe 'The gitsh prompt' do
  it 'is customised by a git config variable' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      expect(gitsh).to prompt_with "#{cwd_basename} master@ "
      gitsh.type('config gitsh.prompt "on %b %#"')
      expect(gitsh).to prompt_with 'on master @ '
      gitsh.type(':set gitsh.prompt "%d:%b%#"')
      expect(gitsh).to prompt_with "#{Dir.getwd}:master@ "
    end
  end
end
