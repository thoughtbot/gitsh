require 'spec_helper'
require 'gitsh/interpreter'
require 'parslet'

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

    it 'handles parse errors' do
      env = stub('env', puts_error: nil)
      parser = stub('Parser')
      parser.stubs(:parse_and_transform).raises(Parslet::ParseFailed, 'Parse failed')
      parser_factory = stub('ParserFactory', new: parser)

      interpreter = Gitsh::Interpreter.new(env, parser_factory: parser_factory)
      interpreter.execute('bad command')

      expect(env).to have_received(:puts_error).with('gitsh: parse error')
    end
  end
end
