require 'spec_helper'
require 'gitsh/prompt_color'

describe Gitsh::PromptColor do
  include Color

  describe '#status_color' do
    context 'with an uninitialized repo' do
      it 'uses the gitsh.color.uninitialized setting' do
        color = stub('color')
        env = stub_env(repo_initialized?: false, repo_config_color: color)
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.uninitialized', 'normal red')
      end
    end

    context 'with untracked files' do
      it 'uses the gitsh.color.untracked setting' do
        color = stub('color')
        env = stub_env(repo_has_untracked_files?: true, repo_config_color: color)
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.untracked', 'red')
      end
    end

    context 'with modified files' do
      it 'uses the gitsh.color.modified setting' do
        color = stub('color')
        env = stub_env(repo_has_modified_files?: true, repo_config_color: color)
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.modified', 'yellow')
      end
    end

    context 'with a clean repo' do
      it 'uses the gitsh.color.default setting' do
        color = stub('color')
        env = stub_env(repo_config_color: color)
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.default', 'blue')
      end
    end
  end

  def stub_env(overrides = {})
    defaults = {
      repo_initialized?: true,
      repo_has_untracked_files?: false,
      repo_has_modified_files?: false,
    }
    env = stub('env', defaults.merge(overrides))
  end
end
