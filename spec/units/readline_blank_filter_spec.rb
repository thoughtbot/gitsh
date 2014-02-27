require 'spec_helper'
require 'gitsh/readline_blank_filter'

describe ReadlineBlankFilter do
  describe '#readline_blank_filter' do
    let(:fake_readline) { FakeReadline.new }
    before { fake_readline::HISTORY.clear }

    it 'enters non-blank lines into the history' do
      readline_blank_filter = ReadlineBlankFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_blank_filter.readline('>', true)

      expect(readline_blank_filter::HISTORY.to_a).to eq(['hello'])
    end

    it 'does not enter blank lines into the history' do
      readline_blank_filter = ReadlineBlankFilter.new(fake_readline)

      fake_readline.type('')
      readline_blank_filter.readline('>', true)

      expect(readline_blank_filter::HISTORY.to_a).to be_empty
    end

    it 'does not enter lines consisting of only whitespace into the history' do
      readline_blank_filter = ReadlineBlankFilter.new(fake_readline)

      fake_readline.type("\n   \n")
      readline_blank_filter.readline('>', true)

      expect(readline_blank_filter::HISTORY.to_a).to be_empty
    end

    it 'does not enter nil lines into the history' do
      readline_blank_filter = ReadlineBlankFilter.new(fake_readline)

      fake_readline.send_eof
      readline_blank_filter.readline('>', true)

      expect(readline_blank_filter::HISTORY.to_a).to be_empty
    end

    it 'does not #pop the last entry to history if add_hist is false' do
      readline_blank_filter = ReadlineBlankFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_blank_filter.readline('>', true)
      fake_readline.type(' ')
      readline_blank_filter.readline('>', false)

      expect(readline_blank_filter::HISTORY.to_a).to eq(['hello'])
    end
  end
end
