require 'spec_helper'
require 'gitsh/cli'

describe '--version' do
  it 'outputs the version, and then exits' do
    output = StringIO.new
    error = StringIO.new

    Gitsh::CLI.new(%w(--version), output, error).run

    expect(error.string).to be_empty
    expect(output.string.chomp).to eq Gitsh::VERSION.to_s
  end
end

describe 'Unexpected arguments' do
  it 'outputs a usage message, and then exits' do
    output = StringIO.new
    error = StringIO.new

    runner = lambda { Gitsh::CLI.new(%w(--badger), output, error).run }

    expect(runner).to raise_error SystemExit
    expect(output.string).to be_empty
    expect(error.string.chomp).to eq 'usage: gitsh [--version]'
  end
end
