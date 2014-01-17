require 'spec_helper'

describe 'The :cd command' do
  it 'changes the current working directory' do
    GitshRunner.interactive do |gitsh|
      gitsh.type 'init'

      Dir.mktmpdir do |path|
        gitsh.type ":cd #{path}"

        expect(gitsh).to output_no_errors
        expect(gitsh).to prompt_with "#{File.basename(path)} uninitialized!! "
      end
    end
  end

  it 'outputs helpful messages when given bad arguments' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':cd /not-a-real-path'

      expect(gitsh).to output_error /gitsh: cd: No such directory/

      gitsh.type ":cd #{__FILE__}"

      expect(gitsh).to output_error /gitsh: cd: Not a directory/

      gitsh.type ':cd'

      expect(gitsh).to output_error 'usage: :cd path'
    end
  end

  it 'expands ~ in paths' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':cd ~'

      expect(gitsh).to output_no_errors
    end
  end
end
