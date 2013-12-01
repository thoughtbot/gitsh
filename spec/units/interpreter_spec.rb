require 'spec_helper'
require 'gitsh/interpreter'

describe Gitsh::Interpreter do
  describe '#execute' do
    it 'transforms the command into an command object and executes it' do
      env = stub
      parsed = stub(execute: nil)
      parser = stub('Parser', parse_and_transform: parsed)
      parser_factory = stub(new: parser)

      interpreter = Gitsh::Interpreter.new(env, parser_factory: parser_factory)
      interpreter.execute('add -p')

      expect(parser).to have_received(:parse_and_transform).with('add -p', env)
      expect(parsed).to have_received(:execute)
    end
  end
end
