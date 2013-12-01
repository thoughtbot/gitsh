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

    driver = stub('driver', execute: nil)
    driver_factory = stub('driver factory', new: driver)

    cli = Gitsh::CLI.new(
      args: [],
      env: env,
      readline: readline,
      driver_factory: driver_factory
    )
    cli.run

    expect(driver).to have_received(:execute).twice
    expect(driver).to have_received(:execute).with('a')
    expect(driver).to have_received(:execute).with('b')
  end
end
