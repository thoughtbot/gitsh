require 'spec_helper'
require 'gitsh/completer'

describe Gitsh::Completer do
  it 'completes commands and aliases' do
    readline = stub('Readline', line_buffer: '')
    git_repo = stub(
      'GitRepo',
      commands: %w( stage stash status add commit ),
      aliases: %w( adder )
    )
    internal_command = stub('InternalCommand', commands: %w( :set :exit ))
    completer = Gitsh::Completer.new(readline, git_repo, internal_command)

    expect(completer.call('sta')).to eq ['stage ', 'stash ', 'status ']
    expect(completer.call('ad')).to eq ['add ', 'adder ']
  end

  it 'completes internal commands' do
    readline = stub('Readline', line_buffer: '')
    git_repo = stub('GitRepo', commands: %w( stage stash ), aliases: [])
    internal_command = stub('InternalCommand', commands: %w( :set :exit ))
    completer = Gitsh::Completer.new(readline, git_repo, internal_command)

    expect(completer.call(':')).to eq [':set ', ':exit ']
    expect(completer.call(':s')).to eq [':set ']
  end

  it 'completes heads when a command has been entered' do
    readline = stub('Readline', line_buffer: 'checkout ')
    git_repo = stub('GitRepo', heads: %w( master my-feature v1.0 ))
    internal_command = stub('InternalCommand')
    completer = Gitsh::Completer.new(readline, git_repo, internal_command)

    expect(completer.call('')).to include 'master ', 'my-feature ', 'v1.0 '
    expect(completer.call('m')).to include 'master ', 'my-feature '
    expect(completer.call('m')).not_to include 'v1.0 '
  end
end
