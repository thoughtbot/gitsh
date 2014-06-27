require 'spec_helper'

describe 'Gitsh variables' do
  it 'can be set with the :set command and read with a dollar prefix' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type(':set author "John Doe <john@example.com>"')

      expect(gitsh).to output_no_errors

      gitsh.type(':set message "An initial commit"')

      expect(gitsh).to output_no_errors

      gitsh.type('commit --allow-empty --author $author -m $message')

      expect(gitsh).to output_no_errors

      gitsh.type('log --format="%ae - %s"')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /^john@example\.com - An initial commit$/
    end
  end

  it 'temporarily adds variables with a dot to git config' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':set test.example "This is a test"')

      expect(gitsh).to output_no_errors

      gitsh.type('config --get test.example')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /This is a test/
    end
  end

  it 'exposes config variables when read with a dot prefix' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('config test.example "A configuration variable"')
      gitsh.type('commit --allow-empty -m "test.example: $test.example"')

      expect(gitsh).to output_no_errors

      gitsh.type('log --format="%s" -n 1')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /test\.example: A configuration variable/
    end
  end

  it 'does not explode when :set is used incorrectly' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':set')

      expect(gitsh).to output_error /usage: :set variable value/
    end
  end

  it 'allows echoing of set variables' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':set greeting hello')
      gitsh.type(':echo $greeting')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /hello/
    end
  end

  it 'does not pass unset variables on to commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':echo "hello $unset world"')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /hello  world/

      gitsh.type(':echo hello $unset world')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /hello world/
    end
  end
end
