require 'spec_helper'

describe 'Subshell' do
  it 'supports subshells using $(...)' do
    GitshRunner.interactive do |gitsh|
      gitsh.type 'init'
      gitsh.type ':echo prefix $(status) suffix'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/prefix.*nothing to commit.*suffix/)
    end
  end

  it 'does not modify the parent environment' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':set x "x in parent shell"'
      gitsh.type ':echo $(:set x "x in subshell")'
      gitsh.type ':echo $x'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/x in parent shell/)
    end
  end

  it 'supports nested subshells' do
    GitshRunner.interactive do |gitsh|
      gitsh.type 'init'
      gitsh.type ':echo $(:echo $(status))'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/nothing to commit/)
    end
  end

  it 'supports adjacent subshells' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':echo $(:echo foo)$(:echo bar)'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/\bfoo\nbar\b/)
    end
  end

  it 'is not confused by quoted parens in a subshell' do
    GitshRunner.interactive do |gitsh|
      gitsh.type ':echo $(:echo ")))")'

      expect(gitsh).to output_no_errors
      expect(gitsh).to output(/\)\)\)/)
    end
  end
end
