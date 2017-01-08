require 'spec_helper'

describe 'Handling errors' do
  it 'does not explode when given an unknown internal command' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':foobar')

      expect(gitsh).to output_error /gitsh: foobar: command not found/
    end
  end

  it 'does not explode when given a badly formatted command' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('add . && || commit')

      expect(gitsh).to output_error /gitsh: parse error/
    end
  end

  it 'does not explode when given a badly formatted script' do
    in_a_temporary_directory do
      write_file('bad.gitsh', ":echo 'foo")

      expect("#{gitsh_path} bad.gitsh").
        to execute.with_exit_status(1).
        with_error_output_matching(/parse error/)
    end
  end
end
