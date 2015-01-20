require 'spec_helper'

describe 'A .gitshrc file in the home directory' do
  context 'when it exists' do
    it 'is loaded when gitsh starts' do
      with_a_temporary_home_directory do
        write_file(gitshrc_path, ':set gitshrc_loaded "Config loaded"')
        GitshRunner.interactive do |gitsh|
          gitsh.type ':echo $gitshrc_loaded'

          expect(gitsh).to output /Config loaded/
          expect(gitsh).to output_no_errors
        end
      end
    end
  end

  context 'when it does not exist' do
    it 'does not cause an error' do
      GitshRunner.interactive do |gitsh|
        expect(File.exist?(gitshrc_path)).to be_false
        expect(gitsh).to output_no_errors
      end
    end
  end

  def gitshrc_path
    "#{ENV['HOME']}/.gitshrc"
  end
end
