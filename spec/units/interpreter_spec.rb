require 'spec_helper'
require 'gitsh/interpreter'
require 'rltk'

describe Gitsh::Interpreter do
  describe '#run' do
    it 'reads, parses, and executes each command from the input strategy' do
      env = double
      command = double(:command, execute: nil)
      parser = double(:parser, parse: command)
      lexer = double('Lexer', lex: tokens([:WORD, 'commit']))
      input_strategy = double(:input_strategy, setup: nil, teardown: nil)
      allow(input_strategy).to receive(:read_command).and_return(
        'first command',
        'second command',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser: parser,
        lexer: lexer,
        input_strategy: input_strategy,
      )

      interpreter.run

      expect(input_strategy).to have_received(:setup).ordered
      expect(lexer).to have_received(:lex).with('first command').ordered
      expect(lexer).to have_received(:lex).with('second command').ordered
      expect(input_strategy).to have_received(:teardown).ordered
      expect(command).to have_received(:execute).with(env).twice
    end

    it 'handles parse errors' do
      env = double(:env, puts_error: nil)
      parser = double(:parser)
      allow(parser).to receive(:parse).
        and_raise(RLTK::NotInLanguage.new([], double(:token), []))
      lexer = double('Lexer', lex: tokens([:WORD, 'commit']))
      input_strategy = double(
        :input_strategy,
        setup: nil,
        teardown: nil,
        handle_parse_error: nil,
      )
      allow(input_strategy).to receive(:read_command).and_return(
        'bad command',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser: parser,
        input_strategy: input_strategy,
      )

      interpreter.run

      expect(input_strategy).
        to have_received(:handle_parse_error).with('parse error')
    end

    it 'handles incomplete input by requesting a completion' do
      env = double
      command = double(:command, execute: nil)
      parser = double(:parser, parse: command)
      lexer = double('Lexer')
      allow(lexer).to receive(:lex).with('(commit').
        and_return(tokens([:LEFT_PAREN], [:WORD, 'commit'], [:MISSING, ')']))
      allow(lexer).to receive(:lex).with("(commit\n)").
        and_return(tokens([:LEFT_PAREN], [:WORD, 'commit'], [:RIGHT_PAREN]))
      input_strategy = double(
        :input_strategy,
        setup: nil,
        teardown: nil,
        read_continuation: ')',
      )
      allow(input_strategy).to receive(:read_command).and_return(
        '(commit',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser: parser,
        input_strategy: input_strategy,
        lexer: lexer,
      )

      interpreter.run

      expect(lexer).to have_received(:lex).
        with('(commit').ordered
      expect(lexer).to have_received(:lex).
        with("(commit\n)").ordered
      expect(parser).to have_received(:parse).once
      expect(command).to have_received(:execute)
    end

    it 'drops the command if the completion is nil' do
      env = double
      parser = double(:parser, parse: nil)
      lexer = double(
        'Lexer',
        lex: tokens([:LEFT_PAREN], [:WORD, 'commit'], [:MISSING, ')']),
      )
      input_strategy = double(
        :input_strategy,
        setup: nil,
        teardown: nil,
        read_continuation: nil,
      )
      allow(input_strategy).to receive(:read_command).and_return(
        'first line',
        nil,
      )
      interpreter = described_class.new(
        env: env,
        parser: parser,
        input_strategy: input_strategy,
        lexer: lexer,
      )

      interpreter.run

      expect(lexer).to have_received(:lex).once
      expect(parser).not_to have_received(:parse)
    end
  end
end
