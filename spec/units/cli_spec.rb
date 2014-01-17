require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  it 'handles a SIGINT' do
    env = stub('Environment', print: nil, repo_initialized?: false, fetch: '')
    readline = stub(
      'readline',
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil
    )
    readline.stubs(:readline).
      returns('a').
      then.raises(Interrupt).
      then.returns('b').
      then.raises(SystemExit)

    interpreter = stub('interpreter', execute: nil)
    interpreter_factory = stub('interpreter factory', new: interpreter)

    cli = Gitsh::CLI.new(
      args: [],
      env: env,
      readline: readline,
      interpreter_factory: interpreter_factory
    )
    begin
      cli.run
    rescue SystemExit
    end

    expect(interpreter).to have_received(:execute).twice
    expect(interpreter).to have_received(:execute).with('a')
    expect(interpreter).to have_received(:execute).with('b')
  end
end
