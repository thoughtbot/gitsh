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

  it 'does not explode when :set is used incorrectly' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':set')

      expect(gitsh).to output_error /usage: :set variable value/
    end
  end
end
