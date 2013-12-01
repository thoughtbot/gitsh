require 'spec_helper'
require 'gitsh/parser'

describe Gitsh::Parser do
  describe '#parse_and_transform' do
    it 'returns an object built from the parsed command' do
      env = stub
      transformed = stub
      transformer = stub('Transformer', apply: transformed)
      transformer_factory = stub(new: transformer)
      parser = described_class.new(transformer_factory: transformer_factory)

      result = parser.parse_and_transform('status', env)

      expect(transformer).to have_received(:apply).with({ git_cmd: 'status' }, env: env)
      expect(result).to eq transformed
    end
  end

  describe '#parse' do
    let(:parser) { described_class.new }

    it 'parses a git command with no arguments' do
      expect(parser).to parse('status').as(git_cmd: 'status')
    end

    it 'parses a git command with trailing whitespace' do
      expect(parser).to parse('status  ').as(git_cmd: 'status')
    end

    it 'parses an internal command with no arguments' do
      expect(parser).to parse(':set').as(internal_cmd: 'set')
    end

    it 'parses a command with a long option argument' do
      expect(parser).to parse('log --format="%ae - %s"').as(
        git_cmd: 'log',
        args: [
          { arg: parser_literals('--format=%ae - %s') }
        ]
      )
    end

    it 'parses a command with string arguments' do
      expect(parser).to parse(%(commit -m "A message" -a 'George')).as(
        git_cmd: 'commit',
        args: [
          { arg: parser_literals('-m') }, { arg: parser_literals('A message') },
          { arg: parser_literals('-a') }, { arg: parser_literals('George') }
        ]
      )
    end

    it 'parses a command with unquoted arguments' do
      expect(parser).to parse(':set author "George"').as(
        internal_cmd: 'set',
        args: [{ arg: parser_literals('author') }, { arg: parser_literals('George') }]
      )
    end

    it 'parses a command with variable arguments' do
      expect(parser).to parse('foo $bar').as(
        git_cmd: 'foo',
        args: [{ arg: [{ var: 'bar' }] }]
      )
    end

    it 'parses a command with unquoted arguments containing variables' do
      expect(parser).to parse('foo prefix$bar ${bar}suffix $path/file').as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix') + [{ var: 'bar' }] },
          { arg: [{ var: 'bar' }] + parser_literals('suffix') },
          { arg: [{ var: 'path' }] + parser_literals('/file') }
        ]
      )
    end

    it 'parses a command with double-quoted arguments containing variables' do
      expect(parser).to parse('foo "prefix $bar" "${bar}suffix" "$path/file"').as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix ') + [{ var: 'bar' }] },
          { arg: [{ var: 'bar' }] + parser_literals('suffix') },
          { arg: [{ var: 'path' }] + parser_literals('/file') }
        ]
      )
    end

    it 'parses a command with single-quoted arguments containing variable-like strings' do
      expect(parser).to parse("foo 'prefix $bar' '${bar}suffix' '$path/file'").as(
        git_cmd: 'foo',
        args: [
          { arg: parser_literals('prefix $bar') },
          { arg: parser_literals('${bar}suffix') },
          { arg: parser_literals('$path/file') }
        ]
      )
    end
  end
end
