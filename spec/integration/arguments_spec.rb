require 'spec_helper'
require 'gitsh/cli'

describe '--version' do
  it 'outputs the version, and then exits' do
    output = StringIO.new
    error = StringIO.new

    runner = lambda do
      Gitsh::CLI.new(args: %w(--version), output: output, error: error).run
    end

    expect(runner).to raise_error SystemExit
    expect(error.string).to be_empty
    expect(output.string.chomp).to eq Gitsh::VERSION.to_s
  end
end

describe 'Unexpected arguments' do
  %w(--badger -x foobar).each do |argument|
    context "with the argument #{argument.inspect}" do
      it 'outputs a usage message and exits' do
        output = StringIO.new
        error = StringIO.new

        runner = lambda do
          Gitsh::CLI.new(args: [argument], output: output, error: error).run
        end

        expect(runner).to raise_error SystemExit
        expect(output.string).to be_empty
        expect(error.string.chomp).to eq(
          'usage: gitsh [--version] [-h | --help] [--git PATH]'
        )
      end
    end
  end
end

describe '--git' do
  it 'uses the requested git binary' do
    fake_git_path = File.expand_path('../../fixtures/fake_git', __FILE__)
    GitshRunner.interactive(args: ['--git', fake_git_path]) do |gitsh|
      gitsh.type('init')

      expect(gitsh).to output_no_errors
      expect(gitsh).to output /^Fake git: init$/
    end
  end
end
