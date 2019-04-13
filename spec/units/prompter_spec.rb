# encoding: utf-8

require 'spec_helper'
require 'gitsh/prompter'

describe Gitsh::Prompter do
  include Color

  describe '#prompt' do
    before do
      register_env
      set_registered_env_value('gitsh.prompt', Gitsh::Prompter::DEFAULT_FORMAT)
    end

    context 'with the default prompt format' do
      context 'an un-initialized git repository' do
        it 'displays an uninitialized prompt' do
          register_repo(
            status: stub_status(initialized?: false),
          )
          prompter = Gitsh::Prompter.new

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}uninitialized!!#{clear} "
          )
        end
      end

      context 'a clean repository' do
        it 'displays the branch name and a clean symbol' do
          register_repo(current_head: 'my-feature', status: stub_status)
          prompter = Gitsh::Prompter.new

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}my-feature@#{clear} "
          )
        end
      end

      context 'a repository with untracked files' do
        it 'displays the branch name and an untracked symbol' do
          register_repo(status: stub_status(
            initialized?: true,
            has_untracked_files?: true,
          ))
          prompter = Gitsh::Prompter.new

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}master!#{clear} "
          )
        end
      end

      context 'a repository with uncommitted changes' do
        it 'displays the branch name an a modified symbol' do
          register_repo(status: stub_status(
            initialized?: true,
            has_modified_files?: true,
            has_untracked_files?: false,
          ))
          prompter = Gitsh::Prompter.new

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}master&#{clear} "
          )
        end
      end

      context 'with color disabled' do
        it 'displays the prompt without colors' do
          register_repo(status: stub_status(
            initialized?: true,
            has_modified_files?: true,
            has_untracked_files?: false,
          ))
          prompter = Gitsh::Prompter.new(color: false)

          expect(prompter.prompt).to eq "#{cwd_basename} master& "
        end
      end

      context 'with a long branch name' do
        it 'displays the shortened branch name' do
          register_repo(
            current_head: "best-branch-name-ever-forever",
            status: stub_status,
          )
          prompter = Gitsh::Prompter.new

          expect(prompter.prompt).to eq "#{cwd_basename} #{red}best-branch-nam…@#{clear} "
        end
      end
    end

    context 'with a custom prompt format' do
      it 'replaces %# with the prompt terminator' do
        set_registered_env_value('gitsh.prompt', "%#")
        register_repo(status: double(
          "Status",
          initialized?: true,
          has_modified_files?: true,
          has_untracked_files?: false,
        ))
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq "& "
      end

      it 'replaces %c with a color code based on the status' do
        set_registered_env_value('gitsh.prompt', "%c")
        register_repo(status: stub_status(
          initialized?: true,
          has_modified_files?: true,
          has_untracked_files?: false,
        ))
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq "#{red} "
      end

      it 'replaces %w with the code to restore the default color' do
        set_registered_env_value('gitsh.prompt', '%w')
        register_repo(status: stub_status)
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq "#{clear} "
      end

      it 'replaces %b with the full current HEAD name' do
        set_registered_env_value('gitsh.prompt', '%b')
        register_repo(
          current_head: 'a-really-long-branch-name',
          status: stub_status,
        )
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq 'a-really-long-branch-name '
      end

      it 'replaces %B with the abbreviated current HEAD name' do
        set_registered_env_value('gitsh.prompt', '%B')
        register_repo(
          current_head: 'a-really-long-branch-name',
          status: stub_status,
        )
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq 'a-really-long-b… '
      end

      it 'replaces %d with the absolute path of the current directory' do
        register_repo
        set_registered_env_value('gitsh.prompt', '%d')
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq "#{Dir.getwd.sub(/\A#{Dir.home}/, '~')} "
      end

      it 'replaces %D with the basename of the current directory' do
        register_repo
        set_registered_env_value('gitsh.prompt', '%D')
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq(
          "#{File.basename(Dir.getwd.sub(/\A#{Dir.home}/, '~'))} "
        )
      end

      it 'replaces %g with the absolute path of the current git binary' do
        register_env(git_command: '/usr/local/bin/my-custom-git')
        set_registered_env_value('gitsh.prompt', '%g')
        register_repo
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq '/usr/local/bin/my-custom-git '
      end

      it 'replaces %G with the basename of the current git binary' do
        register_env(git_command: '/usr/local/bin/my-custom-git')
        set_registered_env_value('gitsh.prompt', '%G')
        register_repo
        prompter = Gitsh::Prompter.new

        expect(prompter.prompt).to eq 'my-custom-git '
      end
    end

    def stub_status(attrs = {})
      default_attrs = {
        initialized?: true,
        has_untracked_files?: false,
        has_modified_files?: false,
      }
      instance_double(Gitsh::GitRepository::Status, default_attrs.merge(attrs))
    end
  end
end
