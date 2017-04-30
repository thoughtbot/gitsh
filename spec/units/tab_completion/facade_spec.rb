require 'spec_helper'
require 'gitsh/tab_completion/facade'

describe Gitsh::TabCompletion::Facade do
  describe '#call' do
    context 'given input not ending with a variable' do
      it 'invokes the CommandCompleter' do
        input = 'add -p $path lib/'
        line_editor = double(:line_editor, line_buffer: input)
        command_completer = stub_command_completer
        stub_variable_completer
        automaton = stub_automaton_factory
        escaper = stub_escaper
        facade = described_class.new(line_editor, double(:env))

        facade.call('lib/')

        expect(Gitsh::TabCompletion::CommandCompleter).to have_received(:new).with(
          line_editor,
          ['add', '-p', '${path}'],
          'lib/',
          automaton,
          escaper,
        )
        expect(command_completer).to have_received(:call)
        expect(Gitsh::TabCompletion::VariableCompleter).
          not_to have_received(:new)
      end
    end

    context 'given input ending with a variable' do
      it 'invokes the VariableCompleter' do
        input = ':echo "name=$g'
        line_editor = double(:line_editor, line_buffer: input)
        stub_command_completer
        variable_completer = stub_variable_completer
        env = double(:env)
        facade = described_class.new(line_editor, env)

        facade.call('name=$g')

        expect(Gitsh::TabCompletion::VariableCompleter).to have_received(:new).with(
          line_editor,
          'name=$g',
          env,
        )
        expect(variable_completer).to have_received(:call)
        expect(Gitsh::TabCompletion::CommandCompleter).
          not_to have_received(:new)
      end
    end
  end

  def stub_command_completer
    stub_class(Gitsh::TabCompletion::CommandCompleter).tap do |completer|
      allow(completer).to receive(:call)
    end
  end

  def stub_variable_completer
    stub_class(Gitsh::TabCompletion::VariableCompleter).tap do |completer|
      allow(completer).to receive(:call)
    end
  end

  def stub_automaton_factory
    stub_class(Gitsh::TabCompletion::AutomatonFactory, :build)
  end

  def stub_escaper
    stub_class(Gitsh::TabCompletion::Escaper)
  end

  def stub_class(klass, method = :new)
    command_completer = instance_double(klass)
    allow(klass).to receive(method).and_return(command_completer)
    command_completer
  end
end
