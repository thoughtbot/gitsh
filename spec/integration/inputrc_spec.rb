require 'spec_helper'

describe 'A .inputrc file in the home directory' do
  RELOAD_INPUTRC = "\cx\cr".freeze

  it 'is used by gitsh' do
    with_a_temporary_home_directory do
      write_file(inputrc_path, <<-INPUTRC)
        $if gitsh
          "\C-xx": ":echo this is a test"
        $endif
      INPUTRC

      GitshRunner.interactive do |gitsh|
        gitsh.type 'init'
        gitsh.type "#{RELOAD_INPUTRC}\cxx"

        expect(gitsh).to output_no_errors
        expect(gitsh).to output(/this is a test/)
      end
    end
  end

  def inputrc_path
    "#{ENV['HOME']}/.inputrc"
  end
end
