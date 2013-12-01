require 'spec_helper'
require 'gitsh/interpreter'

describe Gitsh::Interpreter do
  describe '#execute' do
    it 'passes the command to a git driver' do
      env = stub('env')
      driver = stub('driver', execute: nil)
      driver_factory = stub(new: driver)

      interpreter = described_class.new(env, driver_factory: driver_factory)
      interpreter.execute('add -p')

      expect(driver).to have_received(:execute).with('add -p')
    end
  end
end
