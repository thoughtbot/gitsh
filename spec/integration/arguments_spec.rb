require 'spec_helper'
require 'gitsh/cli'

describe '--version' do
  it 'outputs the version, and then exits' do
    output = StringIO.new
    error = StringIO.new

    Gitsh::CLI.new(args: %w(--version), output: output, error: error).run

    expect(error.string).to be_empty
    expect(output.string.chomp).to eq Gitsh::VERSION.to_s
  end
end

describe 'Unexpected arguments' do
  it 'outputs a usage message, and then exits' do
    output = StringIO.new
    error = StringIO.new

    runner = lambda do
      Gitsh::CLI.new(args: %w(--badger), output: output, error: error).run
    end

    expect(runner).to raise_error SystemExit
    expect(output.string).to be_empty
    expect(error.string.chomp).to eq 'usage: gitsh [--version]'
  end
end
