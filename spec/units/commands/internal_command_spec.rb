require 'spec_helper'
require 'gitsh/commands/internal_command'

describe Gitsh::Commands::InternalCommand do
  describe '.new' do
    it 'returns a Set command when given the command "set"' do
      command = described_class.new('set', %w(foo bar))
      expect(command).to be_a described_class::Set
    end

    it 'returns an Exit command when given the command "exit"' do
      command = described_class.new('exit', [])
      expect(command).to be_a described_class::Exit
    end

    it 'returns an Exit command when given the command "q"' do
      command = described_class.new('q', [])
      expect(command).to be_a described_class::Exit
    end

    it 'returns a Chdir command when given the command "cd"' do
      command = described_class.new('cd', '/some/path')
      expect(command).to be_a described_class::Chdir
    end

    it 'returns a Help command when given the command "help"' do
      command = described_class.new('help', [])
      expect(command).to be_a described_class::Help
    end

    it 'returns a Source command when given the command "source"' do
      command = described_class.new('source', ['/some/path'])
      expect(command).to be_a described_class::Source
    end

    it 'returns an Unknown command when given anything else' do
      command = described_class.new('notacommand', %w(foo bar))
      expect(command).to be_a described_class::Unknown
    end
  end

  describe '.commands' do
    it 'returns a list of recognised commands formatted for autocomplete' do
      expect(described_class.commands).to include ':set', ':exit'
    end
  end

  describe '.command_class' do
    it 'returns a class object corresponding to the command' do
      expect(described_class.command_class('exit')).to eq described_class::Exit
    end

    it 'returns Unknown for an unknown command' do
      expect(described_class.command_class('banana')).to eq described_class::Unknown
    end
  end
end
