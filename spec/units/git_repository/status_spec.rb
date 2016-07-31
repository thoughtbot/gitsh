require 'spec_helper'
require 'gitsh/git_repository/status'

describe Gitsh::GitRepository::Status do
  describe '#initialized?' do
    it 'returns true when git directory exists' do
      repository_git_dir = File.expand_path('../../../../.git', __FILE__)
      status = Gitsh::GitRepository::Status.new('', repository_git_dir)
      expect(status).to be_initialized

      status = Gitsh::GitRepository::Status.new('', '/.git')
      expect(status).not_to be_initialized
    end
  end

  describe "#has_modified_files?" do
    it 'returns true when there are modified files in the repository' do
      status = Gitsh::GitRepository::Status.new(
        "?? example1.txt\n M example2.txt\n",
        ''
      )
      expect(status).to have_modified_files

      status = Gitsh::GitRepository::Status.new(
        "?? example1.txt\n?? example2.txt",
        ''
      )
      expect(status).not_to have_modified_files
    end
  end

  describe "#has_untracked_files?" do
    it 'returns true when there are untracked files in the repository' do
      status = Gitsh::GitRepository::Status.new(
        " M example1.txt\n?? example2.txt\n",
        '',
      )
      expect(status).to have_untracked_files

      status = Gitsh::GitRepository::Status.new(
        " M example1.txt\n M example2.txt\n",
        ''
      )
      expect(status).not_to have_untracked_files
    end
  end
end
