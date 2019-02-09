require 'spec_helper'
require 'gitsh/tab_completion/alias_expander'

describe Gitsh::TabCompletion::AliasExpander do
  describe '#call' do
    context 'when the first word is an alias for a Git command' do
      it 'expands the alias' do
        env = double(:env)
        allow(env).to receive(:fetch).with('alias.alias').
          and_return('expanded command')

        expect(expand(['alias', 'argument'], env)).
          to eq ['expanded', 'command', 'argument']
      end
    end

    context 'when the first word is an alias for a shell command' do
      it 'does not expand the alias' do
        env = double(:env)
        allow(env).to receive(:fetch).with('alias.alias').
          and_return('!shell command')

        expect(expand(['alias', 'argument'], env)).
          to eq ['alias', 'argument']
      end
    end

    context 'when the first word is not an alias' do
      it 'returns the words' do
        env = double(:env)
        allow(env).to receive(:fetch).with('alias.foo').
          and_raise(Gitsh::UnsetVariableError)
        words = ['foo', 'bar']

        expect(expand(words, env)).to eq(words)
      end
    end
  end

  def expand(words, env)
    Gitsh::TabCompletion::AliasExpander.new(words, env).call
  end
end
