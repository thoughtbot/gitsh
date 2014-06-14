require 'spec_helper'

describe 'Executing gitsh scripts' do
  context 'when the path to the script is passed as an argument' do
    it 'runs the script and exits' do
      in_a_temporary_directory do
        write_file('myscript.gitsh', "init\n\ncommit")

        expect("#{gitsh} --git #{fake_git} myscript.gitsh").to execute.
          successfully.
          with_output_matching(/^Fake git: init\nFake git: commit\n$/)
      end
    end

    context 'when the script file does not exist' do
      it 'exits with a useful error message' do
        expect("#{gitsh} --git #{fake_git} noscript.gitsh").to execute.
          with_exit_status(66).
          with_error_output_matching(/^gitsh: noscript\.gitsh: No such file or directory$/)
      end
    end
  end

  def gitsh
    File.expand_path('../../../bin/gitsh', __FILE__)
  end

  def fake_git
    File.expand_path('../../../spec/fixtures/fake_git', __FILE__)
  end
end
