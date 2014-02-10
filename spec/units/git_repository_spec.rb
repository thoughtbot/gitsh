require 'spec_helper'
require 'open3'
require 'gitsh/git_repository'

describe Gitsh::GitRepository do
  describe '#initialized?' do
    it 'returns true when the current directory is a git repository' do
      Dir.chdir(repository_root) do
        expect(Gitsh::GitRepository.new(env)).to be_initialized
      end
    end

    it 'returns false when the current directory is not a git repository' do
      Dir.chdir('/') do
        expect(Gitsh::GitRepository.new(env)).not_to be_initialized
      end
    end
  end

  describe '#current_head' do
    it 'returns the name of the current git branch' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        expect(repo.current_head).to eq 'master'
        run 'git checkout -b my-feature'
        expect(repo.current_head).to eq 'my-feature'
      end
    end

    it 'returns the name of the current git branch with a forward slash' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        run 'git checkout -b feature/foo'
        expect(repo.current_head).to eq 'feature/foo'
      end
    end

    it 'returns the name of an annotated tag if there is no branch' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
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
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        run 'git commit --allow-empty -m "First"'
        run 'git commit --allow-empty -m "Second"'
        run 'git checkout HEAD^'

        expect(repo.current_head).to match /^[a-f0-9]{7}...$/
      end
    end

    it 'returns nil in an uninitialized repository' do
      Dir.chdir('/') do
        repo = Gitsh::GitRepository.new(env)
        expect(repo.current_head).to be_nil
      end
    end
  end

  context '#has_untracked_files?' do
    it 'returns true when there are untracked files in the repository' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
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
        repo = Gitsh::GitRepository.new(env)
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

  context '#heads' do
    it 'produces all the branches and tags' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        run 'git commit --allow-empty -m "Something swell"'
        expect(repo.heads).to eq %w( master )
        run 'git checkout -b awesome-sauce'
        run 'git tag v2.0'
        expect(repo.heads).to eq %w( awesome-sauce master v2.0 )
      end
    end
  end

  context '#commands' do
    it 'produces the list of porcelain commands' do
      repo = Gitsh::GitRepository.new(env)
      expect(repo.commands).to include %(add)
      expect(repo.commands).to include %(commit)
      expect(repo.commands).to include %(checkout)
      expect(repo.commands).to include %(status)
      expect(repo.commands).not_to include %(add--interactive)
      expect(repo.commands).not_to include ''
    end
  end

  context '#aliases' do
    it 'produces the list of aliases' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        run 'git config --local alias.zecho "!echo zzz"'
        run 'git config --local aliasy.notanalias "not an alias"'
        expect(repo.aliases).to include 'zecho'
        expect(repo.aliases).not_to include 'aliasy.notanalias'
        expect(repo.aliases).not_to include 'notanalias'
      end
    end
  end

  context '#config' do
    it 'returns a git configuration value' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        run 'git init'
        run 'git config --local alias.zecho "!echo zzz"'
        expect(repo.config('alias.zecho')).to eq '!echo zzz'
      end
    end

    it 'returns nil if the configuration variable is not set' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        expect(repo.config('not-a.real-variable')).to be_nil
      end
    end

    it 'returns the default value if the configuration variable is not set' do
      in_a_temporary_directory do
        repo = Gitsh::GitRepository.new(env)
        expect(repo.config('not-a.real-variable', 'a-default')).to eq 'a-default'
      end
    end
  end

  def repository_root
    File.expand_path('../../../', __FILE__)
  end

  def run(command)
    Open3.capture3(command)
  end

  def env
    stub(git_command: '/usr/bin/env git')
  end
end
