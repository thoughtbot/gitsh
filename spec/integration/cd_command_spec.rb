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

  it 'changes to the repository root directory when given no arguments' do
    GitshRunner.interactive do |gitsh|
      root_path = Dir.pwd
      gitsh.type 'init'
      Dir.mkdir 'subdir'
      Dir.chdir 'subdir'

      gitsh.type ':cd'

      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with "#{File.basename(root_path)} master@ "
    end
  end

  it 'outputs helpful messages when given bad arguments' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':cd /not-a-real-path'

      expect(gitsh).to output_error /gitsh: cd: No such directory/

      gitsh.type ":cd #{__FILE__}"

      expect(gitsh).to output_error /gitsh: cd: Not a directory/
    end
  end

  it 'expands ~ in paths' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':cd ~'

      expect(gitsh).to output_no_errors
    end
  end
end
