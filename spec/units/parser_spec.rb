require 'spec_helper'
require 'gitsh/parser'

describe Gitsh::Parser do
  describe '#parse_and_transform' do
    it 'returns an object built from the parsed command' do
      transformed = stub
      transformer = stub('Transformer', apply: transformed)
      transformer_factory = stub(new: transformer)
      parser = described_class.new(transformer_factory: transformer_factory)

      result = parser.parse_and_transform('status')

      expect(transformer).to have_received(:apply).with(git_cmd: 'status')
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
      expect(parser).to parse('set author "George"').as(
        git_cmd: 'set',
        args: [{ arg: parser_literals('author') }, { arg: parser_literals('George') }]
      )
    end

  end
end
