require 'spec_helper'
require 'gitsh/interpreter'
require 'parslet'

describe Gitsh::Interpreter do
  describe '#execute' do
    it 'transforms the command into an command object and executes it' do
      env = double
      parsed = spy(execute: nil)
      parser = spy('Parser', parse_and_transform: parsed)
      parser_factory = spy(new: parser)

      interpreter = Gitsh::Interpreter.new(env, parser_factory: parser_factory)
      interpreter.execute('add -p')

      expect(parser_factory).to have_received(:new).with(env: env)
      expect(parser).to have_received(:parse_and_transform).with('add -p')
      expect(parsed).to have_received(:execute)
    end

    it 'handles parse errors' do
      env = spy('env', puts_error: nil)
      parser = double('Parser')
      allow(parser).to receive(:parse_and_transform).
        and_raise(Parslet::ParseFailed, 'Parse failed')
      parser_factory = double('ParserFactory', new: parser)

      interpreter = Gitsh::Interpreter.new(env, parser_factory: parser_factory)
      interpreter.execute('bad command')

      expect(env).to have_received(:puts_error).with('gitsh: parse error')
    end
  end
end
