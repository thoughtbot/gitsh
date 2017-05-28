require 'spec_helper'

describe 'Default git path' do
  it 'can be overridden using a git-config variable' do
    GitshRunner.interactive(
      settings: { 'gitsh.gitCommand' => fake_git_path },
    ) do |gitsh|
      gitsh.type('init')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/^Fake git: init/)
    end
  end

  it 'overrides the configured default when specified with --git' do
    GitshRunner.interactive(
      settings: { 'gitsh.gitCommand' => '/usr/bin/env git' },
      args: ['--git', fake_git_path]
    ) do |gitsh|
      gitsh.type('init')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/^Fake git: init/)
    end
  end
end
