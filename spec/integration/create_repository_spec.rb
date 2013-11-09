require 'spec_helper'
require 'gitsh/cli'

describe 'Creating a repository' do
  it 'is possible through the gish CLI' do
    GitshRunner.interactive do |gitsh|
      expect(gitsh).to prompt_with 'uninitialized!! '

      gitsh.type('init')

      expect(gitsh).to output /^Initialized empty Git repository/
      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with 'master@ '
    end
  end
end
