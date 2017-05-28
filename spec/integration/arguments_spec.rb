require 'spec_helper'
require 'gitsh/cli'
require 'gitsh/environment'

describe '--version' do
  it 'outputs the version, and then exits' do
    output = StringIO.new
    error = StringIO.new
    env = Gitsh::Environment.new(output_stream: output, error_stream: error)

    runner = lambda do
      Gitsh::CLI.new(args: %w(--version), env: env).run
    end

    expect(runner).to raise_error SystemExit
    expect(error.string).to be_empty
    expect(output.string.chomp).to eq Gitsh::VERSION
  end
end

describe 'Unexpected arguments' do
  %w(--badger -x).each do |argument|
    context "with the argument #{argument.inspect}" do
      it 'outputs a usage message and exits' do
        output = StringIO.new
        error = StringIO.new
        env = Gitsh::Environment.new(output_stream: output, error_stream: error)

        runner = lambda do
          Gitsh::CLI.new(args: [argument], env: env).run
        end

        expect(runner).to raise_error SystemExit
        expect(output.string).to be_empty
        expect(error.string.chomp).to eq(
          'usage: gitsh [--version] [-h | --help] [--git PATH] [script]'
        )
      end
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
