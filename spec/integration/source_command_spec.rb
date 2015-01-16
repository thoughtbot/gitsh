require 'spec_helper'

describe 'The :source command' do
  context 'a source file is given' do
    it 'executes the commands in the sourced file' do
      GitshRunner.interactive do |gitsh|
        write_file('.gitshrc', ':set source_worked "Yes it did!"')

        gitsh.type ':source .gitshrc'
        gitsh.type ':echo $source_worked'

        expect(gitsh).to output_no_errors
        expect(gitsh).to output /Yes it did!/
      end
    end
  end

  context 'no source file is given' do
    it 'prints an error message' do
      GitshRunner.interactive do |gitsh|
        gitsh.type ':source'

        expect(gitsh).to output_error /usage/
        expect(gitsh).to output_nothing
      end
    end
  end

  context 'a missing source file is given' do
    it 'prints an error message' do
      GitshRunner.interactive do |gitsh|
        gitsh.type ':source not/a/real/file'

        expect(gitsh).to output_error /No such file/
        expect(gitsh).to output_nothing
      end
    end
  end
end
