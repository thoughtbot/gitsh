require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  it 'handles a SIGINT' do
    env = stub('Environment', {
      print: nil,
      puts: nil,
      repo_initialized?: false,
      fetch: '',
      :[] => nil
    })
    readline = stub('readline', {
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil
    })
    readline.stubs(:readline).
      returns('a').
      then.raises(Interrupt).
      then.returns('b').
      then.raises(SystemExit)

    interpreter = stub('interpreter', execute: nil)
    interpreter_factory = stub('interpreter factory', new: interpreter)

    history = stub('history', load: nil, save: nil)

    cli = Gitsh::CLI.new(
      args: [],
      env: env,
      readline: readline,
      interpreter_factory: interpreter_factory,
      history: history
    )
    begin
      cli.run
    rescue SystemExit
    end

    expect(interpreter).to have_received(:execute).twice
    expect(interpreter).to have_received(:execute).with('a')
    expect(interpreter).to have_received(:execute).with('b')
    expect(env).to have_received(:puts).once
  end
end
