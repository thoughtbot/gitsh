require 'spec_helper'

describe 'Color support' do
  include Color

  it 'is disabled for old terminals' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to prompt_with "#{cwd_basename} uninitialized!! "
    end
  end

  it 'is enabled for color xterm' do
    GitshRunner.interactive(env: { 'TERM' => 'xterm-color' }) do |gitsh|
      expect(gitsh).to prompt_with(
        "#{cwd_basename} #{red_background}uninitialized!!#{clear} "
      )
    end
  end

  it 'allows custom colors from git-config variables' do
    GitshRunner.interactive(env: { 'TERM' => 'xterm-color' }) do |gitsh|
      gitsh.type('config --global gitsh.color.uninitialized red')

      expect(gitsh).to prompt_with(
        "#{cwd_basename} #{red}uninitialized!!#{clear} "
      )
    end
  end

  it 'allows custom colors from gitsh environment variables' do
    GitshRunner.interactive(env: { 'TERM' => 'xterm-color' }) do |gitsh|
      gitsh.type(':set gitsh.color.uninitialized blue')

      expect(gitsh).to prompt_with(
        "#{cwd_basename} #{blue}uninitialized!!#{clear} "
      )
    end
  end
end
