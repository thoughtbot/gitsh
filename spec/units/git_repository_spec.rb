require 'spec_helper'
require 'open3'
require 'gitsh/git_repository'

describe Gitsh::GitRepository do
  include Color

  describe '#git_dir' do
    it 'returns the path to the .git directory' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'

          expect(repo.git_dir).to eq '.git'
        end
      end
    end
  end

  describe '#root_dir' do
    it 'returns the path to the working directory' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          root_dir = Dir.pwd
          repo = Gitsh::GitRepository.new(env)
          run 'git init'

          expect(repo.root_dir).to eq(root_dir)

          run 'mkdir subdir'
          Dir.chdir('./subdir')

          expect(repo.root_dir).to eq(root_dir)
        end
      end
    end

    context 'when called outside of a git repository' do
      it 'returns the empty string' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)

            expect(repo.root_dir).to eq('')
          end
        end
      end
    end
  end

  describe '#current_head' do
    it 'returns the name of the current git branch' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          expect(repo.current_head).to eq 'master'
          run 'git checkout -b my-feature'
          expect(repo.current_head).to eq 'my-feature'
        end
      end
    end

    it 'returns the name of the current git branch with a forward slash' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git checkout -b feature/foo'
          expect(repo.current_head).to eq 'feature/foo'
        end
      end
    end

    it 'returns the name of an annotated tag if there is no branch' do
      with_a_temporary_home_directory do
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
    end

    it 'returns the an abbreviated SHA if there is no branch or tag' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git commit --allow-empty -m "First"'
          run 'git commit --allow-empty -m "Second"'
          run 'git checkout HEAD^'

          expect(repo.current_head).to match(/^[a-f0-9]{7}...$/)
        end
      end
    end

    it 'returns nil in an uninitialized repository' do
      Dir.chdir('/') do
        repo = Gitsh::GitRepository.new(env)
        expect(repo.current_head).to be_nil
      end
    end
  end

  context '#heads' do
    it 'produces all the branches and tags' do
      with_a_temporary_home_directory do
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
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git config --local alias.zecho "!echo zzz"'
          run 'git config --local alias.zecho-with-newline "!echo z\nzz"'
          run 'git config --local aliasy.notanalias "not an alias"'
          expect(repo.aliases).to include 'zecho'
          expect(repo.aliases).to include 'zecho-with-newline'
          expect(repo.aliases).not_to include 'aliasy.notanalias'
          expect(repo.aliases).not_to include 'notanalias'
        end
      end
    end
  end

  context '#config' do
    context 'for a variable that is set' do
      it 'returns a git configuration value' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)
            git_alias = '!echo zzz'
            run 'git init'
            run "git config --local alias.zecho '#{git_alias}'"

            expect(repo.config('alias.zecho')).to eq git_alias
          end
        end
      end
    end

    context 'for a variable that is not set with no block given' do
      it 'raises a KeyError' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)

            expect {
              repo.config('not-a.real-variable')
            }.to raise_exception(KeyError)
          end
        end
      end
    end

    context 'for a variable that is not set with a block' do
      it 'yields to the block' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)

            expect(repo.config('not-a.real-variable') { 'a-default' }).
              to eq 'a-default'
          end
        end
      end
    end
  end

  describe '#available_config_variables' do
    it 'returns a list of all Git configuration variables' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = described_class.new(env)
          run 'git init'
          run 'git config --local user.name "Grace Hopper"'

          expect(repo.available_config_variables).to include(:'user.name')
        end
      end
    end
  end

  context '#config_color' do
    context 'when the config variable is set' do
      it 'returns a color code for the color described by the setting' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)
            run 'git init'
            run 'git config --local example.color red'

            color = repo.config_color('example.color', 'blue')

            expect(color).to eq red
          end
        end
      end
    end

    context 'when the config variable is not set' do
      it 'returns a color code for the color described by the default' do
        with_a_temporary_home_directory do
          in_a_temporary_directory do
            repo = Gitsh::GitRepository.new(env)

            color = repo.config_color('example.color', 'blue')

            expect(color).to eq blue
          end
        end
      end
    end
  end

  context '#color' do
    it 'returns a color code for the color described by the argument' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)

          color = repo.color('blue')

          expect(color).to eq blue
        end
      end
    end
  end

  describe '#revision_name' do
    it 'returns a human-readable name for a revision' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git commit --allow-empty -m "A commit"'

          expect(repo.revision_name('HEAD')).to eq 'master'
        end
      end
    end

    it 'returns nil for an unknown revision' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git commit --allow-empty -m "A commit"'

          expect(repo.revision_name('foobar')).to be_nil
        end
      end
    end
  end

  describe '#merge_base' do
    it 'returns the merge-base of two revisions' do
      with_a_temporary_home_directory do
        in_a_temporary_directory do
          repo = Gitsh::GitRepository.new(env)
          run 'git init'
          run 'git commit --allow-empty -m "Base commit"'
          run 'git checkout -b branch-a master'
          run 'git commit --allow-empty -m "On branch A"'
          run 'git checkout -b branch-b master'
          run 'git commit --allow-empty -m "On branch B"'

          merge_base = repo.merge_base('branch-a', 'branch-b')

          master_sha, _, _ = run('git rev-parse master')
          expect(merge_base).to eq master_sha.chomp
        end
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
    double(git_command: '/usr/bin/env git')
  end
end
