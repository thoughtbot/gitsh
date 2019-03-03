require 'spec_helper'
require 'rltk'
require 'gitsh/tab_completion/dsl/parse_error'

describe Gitsh::TabCompletion::DSL::ParseError do
  describe '#to_s' do
    it 'describes the token where the problem occurred' do
      position = instance_double(
        RLTK::StreamPosition,
        line_number: 2,
        line_offset: 3,
        file_name: 'example.txt',
      )
      token = instance_double(
        RLTK::Token,
        type: :MAYBE,
        position: position,
        value: nil,
      )
      exception = described_class.new('Unexpected', token)

      expect(exception.to_s).to eq(
        'Tab completion configuration error: Unexpected operator (?) '\
        'at line 2, column 4 in file example.txt'
      )
    end
  end
end
