require 'spec_helper'
require 'gitsh/transformer'

describe Gitsh::Transformer do
  describe '#apply' do
    let(:env) { stub }
    let(:transformer) { described_class.new }

    it 'transforms comments' do
      output = transformer.apply({ comment: '#cd' }, env: env)

      expect(output).to be_a Gitsh::Comment
    end

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

    it 'transforms shell commands' do
      output = transformer.apply({ shell_cmd: '!pwd' }, env: env)
      expect(output).to be_a Gitsh::ShellCommand
    end

    it 'transforms shell commands with arguments' do
      output = transformer.apply(
        { shell_cmd: '!echo', args: [{ arg: parser_literals('Hello') }] },
        env: env
      )
      expect(output).to be_a Gitsh::ShellCommand
    end

    it 'transforms literal arguments' do
      output = transformer.apply({ arg: parser_literals('hi') }, env: env)
      expect(output).to eq 'hi'
    end

    it 'transforms variable arguments' do
      env = { 'author' => 'Jane Doe' }
      output = transformer.apply({ arg: [{ var: 'author' }] }, env: env)
      expect(output).to eq 'Jane Doe'
    end

    it 'transforms unknown variables arguments to nil' do
      env = {}
      output = transformer.apply({ arg: [{ var: 'author' }] }, env: env)
      expect(output).to be_nil
    end

    it 'transforms empty string arguments' do
      output = transformer.apply({ arg: [{ empty_string: "''" }] }, env: env)
      expect(output).to eq ''
    end

    it 'transforms multi commands' do
      output = transformer.apply(multi: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Tree::Multi
    end

    it 'transforms or commands' do
      output = transformer.apply(or: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Tree::Or
    end

    it 'transforms and commands' do
      output = transformer.apply(and: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Tree::And
    end
  end
end
