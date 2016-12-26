require 'spec_helper'
require 'gitsh/interpreter'
require 'rltk'

describe Gitsh::Interpreter do
  describe '#run' do
    it 'reads, parses, and executes each command from the input strategy' do
      env = double
      command = double(:command, execute: nil)
      parser = double(:parser, parse: command)
      parser_factory = double(:parser_factory, new: parser)
      tokens = double(:tokens)
      lexer = double('Lexer', lex: tokens)
      input_strategy = double(:input_strategy, setup: nil, teardown: nil)
      allow(input_strategy).to receive(:read_command).and_return(
        'first command',
        'second command',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser_factory: parser_factory,
        lexer: lexer,
        input_strategy: input_strategy,
      )

      interpreter.run

      expect(input_strategy).to have_received(:setup).ordered
      expect(lexer).to have_received(:lex).with('first command').ordered
      expect(lexer).to have_received(:lex).with('second command').ordered
      expect(input_strategy).to have_received(:teardown).ordered
      expect(command).to have_received(:execute).twice
    end

    it 'handles parse errors' do
      env = double(:env, puts_error: nil)
      parser = double(:parser)
      allow(parser).to receive(:parse).
        and_raise(RLTK::NotInLanguage.new([], double(:token), []))
      parser_factory = double('ParserFactory', new: parser)
      lexer = double('Lexer', lex: double(:tokens))
      input_strategy = double(:input_strategy, setup: nil, teardown: nil)
      allow(input_strategy).to receive(:read_command).and_return(
        'bad command',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser_factory: parser_factory,
        input_strategy: input_strategy,
      )

      interpreter.run

      expect(env).to have_received(:puts_error).with('gitsh: parse error')
    end
  end
end
