require 'spec_helper'

describe 'The :help command' do
  it 'outputs a list of available built-in commands' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':help'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output %r(Type :help \[command\] for more specific info)
      expect(gitsh).to output %r(You may use the following built-in commands:)
      expect(gitsh).to output %r(:exit)
    end
  end

  it 'outputs specific help for an individual built-in command' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':help set'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output %r(usage: :set variable value)
      expect(gitsh).to output %r(Sets a variable in the gitsh environment to the given value)
    end
  end
end
