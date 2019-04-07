require 'spec_helper'
require 'gitsh/parser'

describe Gitsh::Parser do
  describe '#parse' do
    it 'parses commands' do
      command = stub_lazy_command

      result = parse(tokens([:WORD, 'commit'], [:EOS]))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'),
      ])
    end

    it 'parses Git commands broken into multiple words' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'com'], [:WORD, 'mit'], [:EOS]
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'),
      ])
    end

    it 'parses commands with arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE], [:WORD, 'WIP'],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'), string('-m'), string('WIP'),
      ])
    end

    it 'parses commands with variable arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE], [:VAR, 'message'],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'), string('-m'), var('message'),
      ])
    end

    it 'parses commands with subshell arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE],
        [:SUBSHELL_START], [:WORD, ':echo'], [:SPACE], [:VAR, 'message'],
        [:SUBSHELL_END], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'), var('message'),
      ])
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'), string('-m'), subshell(command),
      ])
    end

    it 'parses commands with brace expansion in arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE], [:WORD, 'h'],
        [:LEFT_BRACE], [:WORD, 'ello'], [:COMMA], [:WORD, 'i'], [:RIGHT_BRACE],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        composite([
          string('h'),
          brace_expansion([string('ello'), string('i')]),
        ]),
      ])
    end

    it 'parses commands with brace expansion including empty options' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE], [:WORD, 'git'], [:LEFT_BRACE],
        [:COMMA], [:COMMA], [:WORD, 'sh'], [:COMMA], [:COMMA],
        [:RIGHT_BRACE], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        composite([
          string('git'),
          brace_expansion([
            string(''),
            string(''),
            string('sh'),
            string(''),
            string(''),
          ]),
        ]),
      ])
    end

    it 'parses commands with nested brace expansion arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE], [:LEFT_BRACE],
        [:LEFT_BRACE], [:WORD, '1'], [:COMMA], [:WORD, '2'], [:RIGHT_BRACE],
        [:COMMA], [:WORD, '3'], [:RIGHT_BRACE], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        brace_expansion([
          brace_expansion([string('1'), string('2')]),
          string('3'),
        ]),
      ])
    end

    it 'parses commands with adjacent brace expansion in arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE],
        [:WORD, '1'],
        [:LEFT_BRACE], [:WORD, '2'], [:COMMA], [:WORD, '3'], [:RIGHT_BRACE],
        [:LEFT_BRACE], [:WORD, '4'], [:COMMA], [:WORD, '5'], [:COMMA],
          [:WORD, '6'], [:RIGHT_BRACE],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        composite([
          string('1'),
          composite([
            brace_expansion([string('2'), string('3')]),
            brace_expansion([string('4'), string('5'), string('6')]),
          ]),
        ]),
      ])
    end

    it 'parses commands with braces that contain no expansion' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE], [:LEFT_BRACE], [:WORD, 1], [:RIGHT_BRACE],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        composite([
          string('{'),
          string(1),
          string('}'),
        ]),
      ])
    end

    it 'parses commands with empty braces' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, ':echo'], [:SPACE], [:LEFT_BRACE], [:RIGHT_BRACE], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string(':echo'),
        composite([
          string('{'),
          string(''),
          string('}'),
        ]),
      ])
    end

    it 'parses commands with wild-card arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, '!ls'], [:SPACE],
        [:WORD, 'foo'], [:QUESTION_MARK], [:WORD, '.txt'],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('!ls'),
        composite([
          string('foo'),
          composite([
            single_character_glob,
            string('.txt'),
          ]),
        ]),
      ])
    end

    it 'parses commands with composite arguments' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE],
        [:WORD, 'Written by: '],
        [:VAR, 'user.name'], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'),
        string('-m'),
        composite([string('Written by: '), var('user.name')]),
      ])
    end

    it 'parses commands surrounded by parentheses' do
      command = stub_lazy_command

      result = parse(tokens(
        [:LEFT_PAREN], [:WORD, 'commit'], [:RIGHT_PAREN], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'),
      ])
    end

    it 'parses two commands combined with &&' do
      stub_lazy_command

      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:AND], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::And)
    end

    it 'parses two commands combined with ||' do
      stub_lazy_command

      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:OR], [:WORD, ':echo'], [:SPACE], [:WORD, 'Oops'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Or)
    end

    it 'parses two commands combined with ;' do
      stub_lazy_command

      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:SEMICOLON], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Multi)
    end

    it 'parses two commands combined with newlines' do
      stub_lazy_command

      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:EOL], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Multi)
    end

    it 'parses a command with a trailing semicolon' do
      command = stub_lazy_command

      result = parse(tokens(
        [:WORD, 'commit'], [:SEMICOLON], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::LazyCommand).to have_received(:new).with([
        string('commit'),
      ])
    end

    it 'parses blank lines' do
      expect(parse(tokens([:EOS]))).to be_a Gitsh::Commands::Noop
      expect(parse(tokens([:SPACE], [:EOS]))).to be_a Gitsh::Commands::Noop
    end

    it 'does not parse just a semicolon' do
      expect {
        parse(tokens([:SEMICOLON], [:EOS]))
      }.to raise_exception RLTK::NotInLanguage
    end
  end

  def parse(tokens)
    described_class.new.parse(tokens)
  end

  def stub_lazy_command
    command = double(:command)
    allow(Gitsh::Commands::LazyCommand).to receive(:new).and_return(command)
    command
  end

  def string(value)
    Gitsh::Arguments::StringArgument.new(value)
  end

  def var(name)
    Gitsh::Arguments::VariableArgument.new(name)
  end

  def subshell(content)
    Gitsh::Arguments::Subshell.new(content)
  end

  def brace_expansion(options)
    Gitsh::Arguments::BraceExpansion.new(options)
  end

  def single_character_glob
    Gitsh::Arguments::SingleCharacterGlob.new
  end

  def composite(parts)
    Gitsh::Arguments::CompositeArgument.new(parts)
  end
end
