require 'spec_helper'

describe 'Handling errors' do
  it 'does not explode when given an unknown internal command' do
    GitshRunner.interactive do |gitsh|
      gitsh.type(':foobar')

      expect(gitsh).to output_error /gitsh: foobar: command not found/
    end
  end
end
