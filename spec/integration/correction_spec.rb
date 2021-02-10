require 'spec_helper'

describe 'Correcting input' do
  context 'when help.autocorrect is enabled' do
    it 'removes the git prefix from a command' do
      GitshRunner.interactive(
        settings: { "init.defaultBranch" => "master" }
      ) do |gitsh|
        gitsh.type ':set help.autocorrect 1'
        gitsh.type 'git init'

        expect(gitsh).to output_no_errors
        expect(gitsh).to prompt_with "#{cwd_basename} master@ "
      end
    end
  end

  context 'when help.autocorrect is disabled' do
    it 'errors when given a command with a git prefix' do
      GitshRunner.interactive do |gitsh|
        gitsh.type ':set help.autocorrect 0'
        gitsh.type 'git init'

        expect(gitsh).to output_error(/not a git command/)
        expect(gitsh).to prompt_with "#{cwd_basename} uninitialized!! "
      end
    end
  end
end
