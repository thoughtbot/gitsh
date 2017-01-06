require 'spec_helper'
require 'gitsh/argument_builder'

describe Gitsh::ArgumentBuilder do
  describe 'building a StringArgument with #add_literal' do
    it 'concatenates the values passed to subsequent add_literal calls' do
      string_argument = double('StringArgument')
      allow(Gitsh::Arguments::StringArgument).to receive(:new).
        and_return(string_argument)

      built_argument = described_class.build do |builder|
        builder.add_literal('Hello')
        builder.add_literal(' ')
        builder.add_literal('world')
      end

      expect(built_argument).to be string_argument
      expect(Gitsh::Arguments::StringArgument).to have_received(:new).once.
        with('Hello world')
    end
  end

  describe 'building a VariableArgument with #add_variable' do
    it 'creates a variable argument to access the variable' do
      variable_argument = double('VariableArgument')
      allow(Gitsh::Arguments::VariableArgument).to receive(:new).
        and_return(variable_argument)

      built_argument = described_class.build do |builder|
        builder.add_variable('author')
      end

      expect(built_argument).to be variable_argument
      expect(Gitsh::Arguments::VariableArgument).to have_received(:new).once.
        with('author')
    end
  end

  describe 'building a Subshell with #add_subshell' do
    it 'creates a subshell' do
      subshell = double('Subshell')
      allow(Gitsh::Arguments::Subshell).to receive(:new).and_return(subshell)

      built_argument = described_class.build do |builder|
        builder.add_subshell('!pwd')
      end

      expect(built_argument).to be subshell
      expect(Gitsh::Arguments::Subshell).to have_received(:new).once.
        with('!pwd')
    end
  end

  describe 'building a CompositeArgument with multiple calls to #add_variable' do
    it 'creates a composite argument of several VariableArguments' do
      composite_argument = double('CompositeArgument')
      variable_argument = double('VariableArgument')
      allow(Gitsh::Arguments::VariableArgument).to receive(:new).
        and_return(variable_argument)
      allow(Gitsh::Arguments::CompositeArgument).to receive(:new).
        and_return(composite_argument)

      built_argument = described_class.build do |builder|
        builder.add_variable('foo')
        builder.add_variable('bar')
      end

      expect(built_argument).to be composite_argument
      expect(Gitsh::Arguments::CompositeArgument).to have_received(:new).once.
        with([variable_argument, variable_argument])
      expect(Gitsh::Arguments::VariableArgument).to have_received(:new).once.
        with('foo')
      expect(Gitsh::Arguments::VariableArgument).to have_received(:new).once.
        with('bar')
    end
  end

  describe 'building a CompositeArgument with mixed types' do
    it 'creates a composite argument' do
      composite_argument = double('CompositeArgument')
      string_argument = double('StringArgument')
      variable_argument = double('VariableArgument')
      allow(Gitsh::Arguments::CompositeArgument).to receive(:new).and_return(composite_argument)
      allow(Gitsh::Arguments::StringArgument).to receive(:new).and_return(string_argument)
      allow(Gitsh::Arguments::VariableArgument).to receive(:new).and_return(variable_argument)

      built_argument = described_class.build do |builder|
        builder.add_literal('pre')
        builder.add_literal('fix')
        builder.add_variable('foo')
        builder.add_literal('suffix')
      end

      expect(built_argument).to be composite_argument
      expect(Gitsh::Arguments::CompositeArgument).to have_received(:new).once.
        with([string_argument, variable_argument, string_argument])
      expect(Gitsh::Arguments::VariableArgument).to have_received(:new).once.
        with('foo')
      expect(Gitsh::Arguments::StringArgument).to have_received(:new).once.
        with('prefix')
      expect(Gitsh::Arguments::StringArgument).to have_received(:new).once.
        with('suffix')
    end
  end
end
