require 'spec_helper'

describe 'Subshell' do
  it 'supports empty strings' do
    GitshRunner.interactive do |gitsh|
      gitsh.type 'init'
      gitsh.type ':echo prefix $(status) suffix'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /prefix.*nothing to commit.*suffix/
    end
  end

  it 'does not modify the parent environment' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':set x "x in parent shell"'
      gitsh.type ':echo $(:set x "x in subshell")'
      gitsh.type ':echo $x'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /x in parent shell/
    end
  end
end
