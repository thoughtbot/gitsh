require 'spec_helper'
require 'gitsh/cli'

describe 'Creating a repository' do
  it 'is possible through the gish CLI' do
    GitshRunner.interactive(
      settings: { "init.defaultBranch" => "master" }
    ) do |gitsh|
      expect(gitsh).to prompt_with "#{cwd_basename} uninitialized!! "

      gitsh.type('init')

      expect(gitsh).to output(/^Initialized empty Git repository/)
      expect(gitsh).to output_no_errors
      expect(gitsh).to prompt_with "#{cwd_basename} master@ "
    end
  end
end
