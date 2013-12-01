require 'spec_helper'

describe Gitsh::Transformer do
  describe '#apply' do
    let(:transformer) { described_class.new }

    it 'transforms git commands' do
      output = transformer.apply(git_cmd: 'status')
      expect(output).to be_a Gitsh::GitCommand
    end

    it 'transforms git commands with arguments' do
      output = transformer.apply(git_cmd: 'add', args: [{ arg: parser_literals('-p') }])
      expect(output).to be_a Gitsh::GitCommand
    end

    it 'transforms arguments' do
      output = transformer.apply({ arg: parser_literals('hi') })
      expect(output).to eq 'hi'
    end
  end
end
