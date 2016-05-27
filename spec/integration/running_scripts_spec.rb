require 'spec_helper'

describe 'Executing gitsh scripts' do
  context 'when the path to the script is passed as an argument' do
    it 'runs the script and exits' do
      in_a_temporary_directory do
        write_file('myscript.gitsh', "init\n\ncommit")

        expect("#{gitsh} --git #{fake_git_path} myscript.gitsh").to execute.
          successfully.
          with_output_matching(/^Fake git: init\nFake git: commit\n$/)
      end
    end

    context 'when the script file does not exist' do
      it 'exits with a useful error message' do
        expect("#{gitsh} --git #{fake_git_path} noscript.gitsh").to execute.
          with_exit_status(66).
          with_error_output_matching(/^gitsh: noscript\.gitsh: No such file or directory$/)
      end
    end
  end

  context 'when the script is piped to standard input' do
    it 'runs the script and exits' do
      in_a_temporary_directory do
        write_file('myscript.gitsh', "init\n\ncommit")

        expect("cat myscript.gitsh | #{gitsh} --git #{fake_git_path}").
          to execute.successfully.
          with_output_matching(/^Fake git: init\nFake git: commit\n$/)
      end
    end
  end

  def gitsh
    File.expand_path('../../../bin/gitsh', __FILE__)
  end
end
