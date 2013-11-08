require 'spec_helper'
require 'gitsh/cli'

describe 'Creating a repository' do
  it 'is possible through the gish CLI' do
    GitshRunner.interactive do |runner|
      runner.type('init')
      expect(runner.output).to match(/^Initialized empty Git repository/)
      expect(runner.error).to be_empty
    end
  end
end
