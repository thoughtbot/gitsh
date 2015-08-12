require 'spec_helper'

describe 'Magic variables' do
  context '$_prior' do
    it 'evaluates to the name of the previous branch' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type('commit --allow-empty -m "Initial commit"')
        gitsh.type('checkout -b my-feature-branch')
        gitsh.type(':echo $_prior')

        expect(gitsh).to output 'master'

        gitsh.type('checkout $_prior')
        gitsh.type(':echo $_prior')

        expect(gitsh).to output 'my-feature-branch'
      end
    end

    it 'outputs an error when there is no previous branch' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type('commit --allow-empty -m "Initial commit"')
        gitsh.type('branch -d $_prior')

        expect(gitsh).to output_error(/No prior branch/)
      end
    end
  end

  context '$_merge_base' do
    it 'evaluates to the SHA1 of the base commit of an in-progress merge' do
      in_a_repository_with_conflicting_branches do |gitsh|
        gitsh.type('rev-parse master')
        expected_merge_base = gitsh.output
        gitsh.type('checkout branch-b')
        gitsh.type('merge branch-a')

        gitsh.type(':echo $_merge_base')

        expect(gitsh).to output expected_merge_base
      end
    end

    it 'outputs an error when there is no merge in progress' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type(':echo $_merge_base')

        expect(gitsh).to output_error(/No merge in progress/)
      end
    end
  end

  context '$_rebase_base' do
    it 'evaluates to the branch which is the base of an in-progress rebase' do
      in_a_repository_with_conflicting_branches do |gitsh|
        gitsh.type('rev-parse branch-a')
        expected_rebase_base = gitsh.output
        gitsh.type('checkout branch-b')
        gitsh.type('rebase branch-a')

        gitsh.type(':echo $_rebase_base')

        expect(gitsh).to output expected_rebase_base
      end
    end

    it 'outputs an error when there is no rebase in progress' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type(':echo $_rebase_base')

        expect(gitsh).to output_error(/No rebase in progress/)
      end
    end
  end

  def in_a_repository_with_conflicting_branches
    GitshRunner.interactive do |gitsh|
      gitsh.type('init')
      gitsh.type('commit --allow-empty -m Initial')
      write_file('file', 'a')
      gitsh.type('add file')
      gitsh.type('checkout -b branch-a')
      gitsh.type('commit -m A')
      gitsh.type('checkout -b branch-b master')
      write_file('file', 'b')
      gitsh.type('add file')
      gitsh.type('commit -m B')

      yield gitsh
    end
  end
end
