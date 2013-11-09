require 'spec_helper'
require 'gitsh/cli'

describe 'Creating a repository' do
  it 'is possible through the gish CLI' do
    GitshRunner.interactive do |runner|
      expect(runner.prompt).to eq 'uninitialized!! '

      runner.type('init')

      expect(runner.output).to match(/^Initialized empty Git repository/)
      expect(runner.error).to be_empty

      expect(runner.prompt).to eq 'master@ '
    end
  end
end
