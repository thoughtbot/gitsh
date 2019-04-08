require 'spec_helper'
require 'gitsh/prompt_color'

describe Gitsh::PromptColor do
  include Color

  describe '#status_color' do
    context 'with an uninitialized repo' do
      it 'uses the gitsh.color.uninitialized setting' do
        setup_env('gitsh.color.uninitialized' => 'normal blue')
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(initialized?: false)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('normal blue')
      end

      it 'uses a default when the setting is not present' do
        setup_env
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(initialized?: false)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('normal red')
      end
    end

    context 'with untracked files' do
      it 'uses the gitsh.color.untracked setting' do
        setup_env('gitsh.color.untracked' => 'normal blue')
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(has_untracked_files?: true)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('normal blue')
      end

      it 'uses a default when the setting is not present' do
        setup_env
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(has_untracked_files?: true)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('red')
      end
    end

    context 'with modified files' do
      it 'uses the gitsh.color.modified setting' do
        setup_env('gitsh.color.modified' => 'normal blue')
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(has_modified_files?: true)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('normal blue')
      end

      it 'uses a default when the setting is not present' do
        setup_env
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status(has_modified_files?: true)

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('yellow')
      end
    end

    context 'with a clean repo' do
      it 'uses the gitsh.color.default setting' do
        setup_env('gitsh.color.default' => 'normal yellow')
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('normal yellow')
      end

      it 'uses a default when the setting is not present' do
        setup_env
        color = double('color')
        repo = register_repo(color: color)
        prompt_color = described_class.new
        status = stub_status

        expect(prompt_color.status_color(status)).to eq color
        expect(repo).to have_received(:color).with('blue')
      end
    end
  end

  def setup_env(vars = {})
    env = register_env
    allow(env).to receive(:fetch).and_yield
    vars.each do |name, value|
      allow(env).to receive(:fetch).with(name).and_return(value)
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
