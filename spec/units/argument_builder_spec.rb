require 'spec_helper'
require 'gitsh/argument_builder'

describe Gitsh::ArgumentBuilder do
  describe 'building a StringArgument with #add_literal' do
    it 'concatenates the values passed to subsequent add_literal calls' do
      string_argument = stub('StringArgument')
      Gitsh::Arguments::StringArgument.stubs(:new).returns(string_argument)

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
      variable_argument = stub('VariableArgument')
      Gitsh::Arguments::VariableArgument.stubs(:new).returns(variable_argument)

      built_argument = described_class.build do |builder|
        builder.add_variable('author')
      end

      expect(built_argument).to be variable_argument
      expect(Gitsh::Arguments::VariableArgument).to have_received(:new).once.
        with('author')
    end
  end

  describe 'building a CompositeArgument with multiple calls to #add_variable' do
    it 'creates a composite argument of several VariableArguments' do
      composite_argument = stub('CompositeArgument')
      variable_argument = stub('VariableArgument')
      Gitsh::Arguments::VariableArgument.stubs(:new).returns(variable_argument)
      Gitsh::Arguments::CompositeArgument.stubs(:new).returns(composite_argument)

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
      composite_argument = stub('CompositeArgument')
      string_argument = stub('StringArgument')
      variable_argument = stub('VariableArgument')
      Gitsh::Arguments::CompositeArgument.stubs(:new).returns(composite_argument)
      Gitsh::Arguments::StringArgument.stubs(:new).returns(string_argument)
      Gitsh::Arguments::VariableArgument.stubs(:new).returns(variable_argument)

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
