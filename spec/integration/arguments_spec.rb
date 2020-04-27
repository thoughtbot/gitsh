require 'spec_helper'
require 'gitsh/cli'
require 'gitsh/environment'

describe 'When passed arguments' do
  describe '--version' do
    it 'outputs the version, and then exits' do
      setup_repo
      output, error = setup_output_streams

      runner = lambda do
        Gitsh::CLI.new(%w(--version)).run
      end

      expect(runner).to raise_error SystemExit
      expect(error.string).to be_empty
      expect(output.string.chomp).to eq Gitsh::VERSION
    end
  end

  %w(--badger -x).each do |argument|
    describe argument do
      it 'outputs a usage message and exits' do
        setup_repo
        output, error = setup_output_streams

        runner = lambda do
          Gitsh::CLI.new([argument]).run
        end

        expect(runner).to raise_error SystemExit
        expect(output.string).to be_empty
        expect(error.string.chomp).to eq(
          'usage: gitsh [--version] [-h | --help] [--git PATH] [script]'
        )
      end
    end
  end

  describe '--git' do
    it 'uses the requested git binary' do
      GitshRunner.interactive(args: ['--git', fake_git_path]) do |gitsh|
        gitsh.type('init')

        expect(gitsh).to output_no_errors
        expect(gitsh).to output(/^Fake git: init$/)
      end
    end
  end

  def setup_repo
    register(repo: Gitsh::GitRepository.new)
  end

  def setup_output_streams
    output = StringIO.new
    error = StringIO.new
    env = Gitsh::Environment.new(output_stream: output, error_stream: error)
    register(env: env)
    [output, error]
  end
end
