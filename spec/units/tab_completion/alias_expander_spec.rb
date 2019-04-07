require 'spec_helper'
require 'gitsh/tab_completion/alias_expander'

describe Gitsh::TabCompletion::AliasExpander do
  describe '#call' do
    context 'when the first word is an alias for a Git command' do
      it 'expands the alias' do
        register_env
        allow(Gitsh::Registry.env).to receive(:fetch).with('alias.alias').
          and_return('expanded command')

        expect(expand(['alias', 'argument'])).
          to eq ['expanded', 'command', 'argument']
      end
    end

    context 'when the first word is an alias for a shell command' do
      it 'does not expand the alias' do
        register_env
        allow(Gitsh::Registry.env).to receive(:fetch).with('alias.alias').
          and_return('!shell command')

        expect(expand(['alias', 'argument'])).
          to eq ['alias', 'argument']
      end
    end

    context 'when the first word is not an alias' do
      it 'returns the words' do
        register_env
        allow(Gitsh::Registry.env).to receive(:fetch).with('alias.foo').
          and_raise(Gitsh::UnsetVariableError)
        words = ['foo', 'bar']

        expect(expand(words)).to eq(words)
      end
    end
  end

  def expand(words)
    Gitsh::TabCompletion::AliasExpander.new(words).call
  end
end
