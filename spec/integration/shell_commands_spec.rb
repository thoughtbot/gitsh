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

  it 'accepts a relative shell command with no arguments' do
    GitshRunner.interactive do |gitsh|
      IO.write('./script', "#!/bin/sh\necho Hello world", 0, perm: 0700)

      gitsh.type '!./script'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output 'Hello world'
    end
  end

  it 'handles errors gracefully' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '!notarealcommand'

      expect(gitsh).to output_error(/No such file or directory - notarealcommand/)
      expect(gitsh).to output_nothing
    end
  end
end
