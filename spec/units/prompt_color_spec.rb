require 'spec_helper'
require 'gitsh/prompt_color'

describe Gitsh::PromptColor do
  include Color

  describe '#status_color' do
    context 'with an uninitialized repo' do
      it 'uses the gitsh.color.uninitialized setting' do
        color = double('color')
        env = double('env', repo_config_color: color)
        prompt_color = described_class.new(env)
        status = double('status', initialized?: false)

        expect(prompt_color.status_color(status)).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.uninitialized', 'normal red')
      end
    end

    context 'with untracked files' do
      it 'uses the gitsh.color.untracked setting' do
        color = double('color')
        env = double('env', repo_config_color: color)
        status = double(
          'status',
          initialized?: true,
          has_untracked_files?: true,
        )
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color(status)).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.untracked', 'red')
      end
    end

    context 'with modified files' do
      it 'uses the gitsh.color.modified setting' do
        color = double('color')
        env = double('env', repo_config_color: color)
        status = double(
          'status',
          initialized?: true,
          has_untracked_files?: false,
          has_modified_files?: true,
        )
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color(status)).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.modified', 'yellow')
      end
    end

    context 'with a clean repo' do
      it 'uses the gitsh.color.default setting' do
        color = double('color')
        env = double('env', repo_config_color: color)
        status = double(
          'status',
          initialized?: true,
          has_untracked_files?: false,
          has_modified_files?: false,
        )
        prompt_color = described_class.new(env)

        expect(prompt_color.status_color(status)).to eq color
        expect(env).to have_received(:repo_config_color).
          with('gitsh.color.default', 'blue')
      end
    end
  end
end
