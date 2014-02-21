require 'spec_helper'

describe 'Executing a shell command' do
  it 'accepts a shell command prefixed with a !' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '!echo Hello world'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output 'Hello world'
    end
  end

  it 'accepts a shell command with no arguments' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '!pwd'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(Dir.getwd)
    end
  end
end
