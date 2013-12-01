require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  it 'handles a SIGINT' do
    env = stub(print: nil)
    readline = stub(
      'readline',
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil
    )
    readline.stubs(:readline).
      returns('a').
      then.raises(Interrupt).
      then.returns('b').
      then.returns('exit')

    interpreter = stub('interpreter', execute: nil)
    interpreter_factory = stub('interpreter factory', new: interpreter)

    cli = Gitsh::CLI.new(
      args: [],
      env: env,
      readline: readline,
      interpreter_factory: interpreter_factory
    )
    cli.run

    expect(interpreter).to have_received(:execute).twice
    expect(interpreter).to have_received(:execute).with('a')
    expect(interpreter).to have_received(:execute).with('b')
  end
end
