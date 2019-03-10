require 'spec_helper'
require 'gitsh/parser'

describe Gitsh::Parser do
  describe '#parse' do
    it 'parses Git commands' do
      command = stub_command_factory

      result = parse(tokens([:WORD, 'commit'], [:EOS]))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit', args: [],
      )
    end

    it 'parses internal commands' do
      command = stub_command_factory

      result = parse(tokens([:WORD, ':echo'], [:EOS]))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::InternalCommand,
        command: 'echo', args: [],
      )
    end

    it 'parses shell commands' do
      command = stub_command_factory

      result = parse(tokens([:WORD, '!ls'], [:EOS]))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::ShellCommand,
        command: 'ls', args: [],
      )
    end

    it 'parses Git commands broken into multiple words' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'com'], [:WORD, 'mit'], [:EOS]
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit', args: [],
      )
    end

    it 'parses commands with arguments' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE], [:WORD, 'WIP'],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit',
        args: [string('-m'), string('WIP')],
      )
    end

    it 'parses commands with variable arguments' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE], [:VAR, 'message'],
        [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit',
        args: [string('-m'), var('message')],
      )
    end

    it 'parses commands with subshell arguments' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE],
        [:SUBSHELL_START], [:WORD, ':echo'], [:SPACE], [:VAR, 'message'],
        [:SUBSHELL_END], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::InternalCommand,
        command: 'echo',
        args: [var('message')],
      )
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit',
        args: [string('-m'), subshell(command)],
      )
    end

    it 'parses commands with composite arguments' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'commit'], [:SPACE], [:WORD, '-m'], [:SPACE],
        [:WORD, 'Written by: '],
        [:VAR, 'user.name'], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit',
        args: [
          string('-m'),
          composite([string('Written by: '), var('user.name'),]),
        ],
      )
    end

    it 'parses commands surrounded by parentheses' do
      command = stub_command_factory

      result = parse(tokens(
        [:LEFT_PAREN], [:WORD, 'commit'], [:RIGHT_PAREN], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit',
        args: [],
      )
    end

    it 'parses two commands combined with &&' do
      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:AND], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::And)
    end

    it 'parses two commands combined with ||' do
      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:OR], [:WORD, ':echo'], [:SPACE], [:WORD, 'Oops'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Or)
    end

    it 'parses two commands combined with ;' do
      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:SEMICOLON], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Multi)
    end

    it 'parses two commands combined with |' do
      result = parse(tokens(
        [:WORD, 'log'], [:PIPE], [:WORD, '!wc'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Pipeline)
    end

    it 'parses two commands combined with newlines' do
      result = parse(tokens(
        [:WORD, 'add'], [:SPACE], [:WORD, '.'],
        [:EOL], [:WORD, 'commit'], [:EOS],
      ))

      expect(result).to be_a(Gitsh::Commands::Tree::Multi)
    end

    it 'parses a command with a trailing semicolon' do
      command = stub_command_factory

      result = parse(tokens(
        [:WORD, 'commit'], [:SEMICOLON], [:EOS],
      ))

      expect(result).to eq command
      expect(Gitsh::Commands::Factory).to have_received(:build).with(
        Gitsh::Commands::GitCommand,
        command: 'commit', args: [],
      )
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

  def stub_command_factory
    command = double(:command)
    allow(Gitsh::Commands::Factory).to receive(:build).and_return(command)
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

  def composite(parts)
    Gitsh::Arguments::CompositeArgument.new(parts)
  end
end
