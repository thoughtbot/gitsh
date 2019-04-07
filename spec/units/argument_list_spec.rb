require 'spec_helper'
require 'gitsh/argument_list'

describe Gitsh::ArgumentList do
  describe '#length' do
    it 'returns the number of arguments' do
      argument_list = Gitsh::ArgumentList.new([double, double])

      expect(argument_list.length).to eq 2
    end
  end

  describe '#values' do
    it 'returns the values of the arguments' do
      env = double('env')
      hello_arg = spy('hello_arg', value: [string_value('hello')])
      goodbye_arg = spy('goodbye_arg', value: [string_value('goodbye')])
      argument_list = Gitsh::ArgumentList.new([hello_arg, goodbye_arg])
      completer = stub_completer

      values = argument_list.values(env, completer)

      expect(values).to eq ['hello', 'goodbye']
      expect(hello_arg).to have_received(:value).with(env)
      expect(goodbye_arg).to have_received(:value).with(env)
    end

    it 'expands patterns' do
      env = double('env')
      pattern_arg = spy('pattern_arg', value: [pattern_value('foo.', 'foo?')])
      argument_list = Gitsh::ArgumentList.new([pattern_arg])
      completer = stub_completer(
        ['foo1', 'foo2', 'bar1', 'foo12345'],
      )

      values = argument_list.values(env, completer)

      expect(values).to eq ['foo1', 'foo2']
    end
  end

  def stub_completer(completions = [])
    instance_double(
      Gitsh::TabCompletion::Automaton,
      session: stub_completer_session(completions),
    )
  end

  def stub_completer_session(completions = [])
    completer_session = instance_double(
      Gitsh::TabCompletion::Automaton::Session,
      completions: completions,
    )
    allow(completer_session).
      to receive(:step_through).and_return(completer_session)
    completer_session
  end
end
