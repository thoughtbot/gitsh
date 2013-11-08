require 'spec_helper'
require 'open3'
require 'gitsh/git_repository'

describe Gitsh::GitRepository do
  describe '#initialized?' do
    it 'returns true when the current directory is a git repository' do
      Dir.chdir(repository_root) do
        expect(Gitsh::GitRepository.new).to be_initialized
      end
    end

    it 'returns false when the current directory is not a git repository' do
      Dir.chdir('/') do
        expect(Gitsh::GitRepository.new).not_to be_initialized
      end
    end
  end

  describe '#current_head' do
    it 'returns the name of the current git branch' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new
        run 'git init'
        expect(repo.current_head).to eq 'master'
        run 'git checkout -b my-feature'
        expect(repo.current_head).to eq 'my-feature'
      end
    end

    it 'returns the name of an annotated tag if there is no branch' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new
        run 'git init'
        run 'git commit --allow-empty -m "First"'
        run 'git tag -m "Tag pointing to first" first'
        run 'git commit --allow-empty -m "Second"'
        run 'git checkout first'

        expect(repo.current_head).to eq 'first'
      end
    end

    it 'returns the an abbreviated SHA if there is no branch or tag' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new
        run 'git init'
        run 'git commit --allow-empty -m "First"'
        run 'git commit --allow-empty -m "Second"'
        run 'git checkout HEAD^'

        expect(repo.current_head).to match /^[a-f0-9]{7}...$/
      end
    end

    it 'returns nil in an uninitialized repository' do
      Dir.chdir('/') do
        repo = Gitsh::GitRepository.new
        expect(repo.current_head).to be_nil
      end
    end
  end

  context '#has_untracked_files?' do
    it 'returns true when there are untracked files in the repository' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new
        run 'git init'
        expect(repo).not_to have_untracked_files
        write_file 'example.txt'
        expect(repo).to have_untracked_files
      end
    end
  end

  context '#has_modified_files?' do
    it 'returns true when there are modified files' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new
        run 'git init'
        write_file 'example.txt'
        expect(repo).not_to have_modified_files
        run 'git add example.txt'
        expect(repo).to have_modified_files
        run 'git commit -m "Add example.txt"'
        expect(repo).not_to have_modified_files
      end
    end
  end

  def repository_root
    File.expand_path('../../../', __FILE__)
  end

  def in_a_temporary_directory(&block)
    Dir.mktmpdir do |path|
      Dir.chdir(path, &block)
    end
  end

  def run(command)
    Open3.capture3(command)
  end

  def write_file(name, contents="Some content")
    File.open("./#{name}", 'w') { |f| f << "#{contents}\n" }
  end
end
