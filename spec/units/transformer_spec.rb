require 'spec_helper'

describe Gitsh::Transformer do
  describe '#apply' do
    let(:env) { stub }
    let(:transformer) { described_class.new }

    it 'transforms git commands' do
      output = transformer.apply({ git_cmd: 'status' }, env: env)
      expect(output).to be_a Gitsh::GitCommand
    end

    it 'transforms git commands with arguments' do
      output = transformer.apply(
        { git_cmd: 'add', args: [{ arg: parser_literals('-p') }] },
        env: env
      )
      expect(output).to be_a Gitsh::GitCommand
    end

    it 'transforms args with empty strings passed to them' do
      output = transformer.apply({ arg: '' }, env: env)
      expect(output).to eq ''
    end

    it 'transforms internal commands' do
      output = transformer.apply({ internal_cmd: 'set' }, env: env)
      expect(output).to be_a Gitsh::InternalCommand::Set
    end

    it 'transforms internal commands with arguments' do
      output = transformer.apply(
        { internal_cmd: 'set', args: [{ arg: parser_literals('hi') }] },
        env: env
      )
      expect(output).to be_a Gitsh::InternalCommand::Set
    end

    it 'transforms literal arguments' do
      output = transformer.apply({ arg: parser_literals('hi') }, env: env)
      expect(output).to eq 'hi'
    end

    it 'transforms variable arguments' do
      env = { 'author' => 'Jane Doe' }
      output = transformer.apply({ var: 'author' }, env: env)
      expect(output).to eq 'Jane Doe'
    end
  end
end
