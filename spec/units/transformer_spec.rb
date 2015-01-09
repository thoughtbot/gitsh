require 'spec_helper'
require 'gitsh/transformer'

describe Gitsh::Transformer do
  describe '#apply' do
    let(:env) { stub }
    let(:transformer) { described_class.new }

    it 'transforms blank lines' do
      output = transformer.apply({ blank: '' }, env: env)

      expect(output).to be_a Gitsh::Commands::Noop
    end

    it 'transforms comments' do
      output = transformer.apply({ comment: '#cd' }, env: env)

      expect(output).to be_a Gitsh::Commands::Noop
    end

    it 'transforms git commands' do
      output = transformer.apply({ git_cmd: 'status' }, env: env)
      expect(output).to be_a Gitsh::Commands::GitCommand
    end

    it 'transforms git commands with arguments' do
      output = transformer.apply(
        { git_cmd: 'add', args: [{ arg: parser_literals('-p') }] },
        env: env
      )
      expect(output).to be_a Gitsh::Commands::GitCommand
    end

    it 'transforms internal commands' do
      output = transformer.apply({ internal_cmd: 'set' }, env: env)
      expect(output).to be_a Gitsh::Commands::InternalCommand::Set
    end

    it 'transforms internal commands with arguments' do
      output = transformer.apply(
        { internal_cmd: 'set', args: [{ arg: parser_literals('hi') }] },
        env: env
      )
      expect(output).to be_a Gitsh::Commands::InternalCommand::Set
    end

    it 'transforms shell commands' do
      output = transformer.apply({ shell_cmd: '!pwd' }, env: env)
      expect(output).to be_a Gitsh::Commands::ShellCommand
    end

    it 'transforms shell commands with arguments' do
      output = transformer.apply(
        { shell_cmd: '!echo', args: [{ arg: parser_literals('Hello') }] },
        env: env
      )
      expect(output).to be_a Gitsh::Commands::ShellCommand
    end

    it 'transforms literal arguments' do
      argument_builder = stub_argument_builder
      output = transformer.apply({ arg: parser_literals('hi') }, env: env)

      expect(argument_builder).to have_received(:add_literal).with('h')
      expect(argument_builder).to have_received(:add_literal).with('i')
      expect(output).to be argument_builder.argument
    end

    it 'transforms variable arguments' do
      argument_builder = stub_argument_builder
      output = transformer.apply({ arg: [{ var: 'author' }] }, env: env)

      expect(argument_builder).to have_received(:add_variable).with('author')
      expect(output).to be argument_builder.argument
    end

    it 'transforms empty string arguments' do
      output = transformer.apply({ arg: [{ empty_string: "''" }] }, env: env)
      expect(output.value(env)).to eq ''
    end

    it 'transforms multi commands' do
      output = transformer.apply(multi: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Commands::Tree::Multi
    end

    it 'transforms or commands' do
      output = transformer.apply(or: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Commands::Tree::Or
    end

    it 'transforms and commands' do
      output = transformer.apply(and: { left: 1, right: 2 })
      expect(output).to be_a Gitsh::Commands::Tree::And
    end
  end

  def stub_argument_builder
    argument = stub('Argument')
    builder = stub(
      'ArgumentBuilder',
      add_literal: nil,
      add_variable: nil,
      argument: argument,
    )
    Gitsh::ArgumentBuilder.stubs(:build).yields(builder).returns(argument)
    builder
  end
end
