# encoding: utf-8

require 'spec_helper'

describe 'The gitsh prompt' do
  it 'defaults to the directory basename and the branch name' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')

      expect(gitsh).to prompt_with "#{cwd_basename} master@ "
    end
  end

  it 'defaults to abbreviated branch names' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type("checkout -b best-branch-name-ever-forever")

      expect(gitsh).to prompt_with "#{cwd_basename} best-branch-nam…@ "
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

  it 'displays the repository status using prompt sigils' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to prompt_with "#{cwd_basename} uninitialized!! "

      gitsh.type('init')

      expect(gitsh).to prompt_with "#{cwd_basename} master@ "

      write_file 'example.txt'
      gitsh.type('')

      expect(gitsh).to prompt_with "#{cwd_basename} master! "

      gitsh.type('add --intent-to-add example.txt')

      expect(gitsh).to prompt_with "#{cwd_basename} master& "
    end
  end
end
