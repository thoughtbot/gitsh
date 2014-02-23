require 'spec_helper'

describe 'Transformer' do
  it 'does not explode when given an empty string' do
    GitshRunner.interactive do |gitsh|
      gitsh.type('commit -m "Do something." -m "" -m "And something else."')

      expect(gitsh).to output_error /Not a git repository/
    end
  end
end
