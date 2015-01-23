# encoding: utf-8

require 'spec_helper'
require 'gitsh/prompter'

describe Gitsh::Prompter do
  include Color

  describe '#prompt' do
    context 'with the default prompt format' do
      context 'an un-initialized git repository' do
        it 'displays an uninitialized prompt' do
          env = env_double(repo_initialized?: false)
          prompter = Gitsh::Prompter.new(env: env)

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}uninitialized!!#{clear} "
          )
        end
      end

      context 'a clean repository' do
        it 'displays the branch name and a clean symbol' do
          env = env_double(repo_current_head: 'my-feature')
          prompter = Gitsh::Prompter.new(env: env)

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}my-feature@#{clear} "
          )
        end
      end

      context 'a repository with untracked files' do
        it 'displays the branch name and an untracked symbol' do
          env = env_double(repo_has_untracked_files?: true)
          prompter = Gitsh::Prompter.new(env: env)

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}master!#{clear} "
          )
        end
      end

      context 'a repository with uncommitted changes' do
        it 'displays the branch name an a modified symbol' do
          env = env_double(repo_has_modified_files?: true)
          prompter = Gitsh::Prompter.new(env: env)

          expect(prompter.prompt).to eq(
            "#{cwd_basename} #{red}master&#{clear} "
          )
        end
      end

      context 'with color disabled' do
        it 'displays the prompt without colors' do
          env = env_double(repo_has_modified_files?: true)
          prompter = Gitsh::Prompter.new(color: false, env: env)

          expect(prompter.prompt).to eq "#{cwd_basename} master& "
        end
      end

      context 'with a long branch name' do
        it 'displays the shortened branch name' do
          env = env_double(repo_current_head: "best-branch-name-ever-forever")
          prompter = Gitsh::Prompter.new(env: env)

          expect(prompter.prompt).to eq "#{cwd_basename} #{red}best-branch-nam…@#{clear} "
        end
      end
    end

    context 'with a custom prompt format' do
      it 'replaces %# with the prompt terminator' do
        env = env_double(repo_has_modified_files?: true, format: '%#')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "& "
      end

      it 'replaces %c with a color code based on the status' do
        prompt_color = double('PromptColor', status_color: blue)
        env = env_double(repo_has_modified_files?: true, format: '%c')
        prompter = Gitsh::Prompter.new(env: env, prompt_color: prompt_color)

        expect(prompter.prompt).to eq "#{blue} "
      end

      it 'replaces %w with the code to restore the default color' do
        env = env_double(format: '%w')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{clear} "
      end

      it 'replaces %b with the full current HEAD name' do
        env = env_double(
          repo_current_head: 'a-really-long-branch-name',
          format: '%b',
        )
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq 'a-really-long-branch-name '
      end

      it 'replaces %B with the abbreviated current HEAD name' do
        env = env_double(
          repo_current_head: 'a-really-long-branch-name',
          format: '%B',
        )
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq 'a-really-long-b… '
      end

      it 'replaces %d with the absolute path of the current directory' do
        env = env_double(format: '%d')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{Dir.getwd} "
      end

      it 'replaces %D with the basename of the current directory' do
        env = env_double(format: '%D')
        prompter = Gitsh::Prompter.new(env: env)

        expect(prompter.prompt).to eq "#{File.basename(Dir.getwd)} "
      end
    end

    def env_double(attrs={})
      format = attrs.delete(:format)
      default_attrs = {
        repo_initialized?: true,
        repo_has_modified_files?: false,
        repo_has_untracked_files?: false,
        repo_current_head: 'master',
        repo_config_color: red,
      }
      double('Environment', default_attrs.merge(attrs)).tap do |env|
        allow(env).to receive(:[]).with('gitsh.prompt').and_return(format)
        allow(env).to receive(:fetch).with('gitsh.prompt').and_return(
          format || Gitsh::Prompter::DEFAULT_FORMAT
        )
      end
    end
  end
end
