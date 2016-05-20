require 'spec_helper'
require 'gitsh/readline_history_filter'

describe ReadlineHistoryFilter do
  describe '#readline_history_filter' do
    let(:fake_readline) { FakeReadline.new }
    before { fake_readline::HISTORY.clear }

    it 'enters non-blank lines into the history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to eq(['hello'])
    end

    it 'does not enter blank lines into the history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('')
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to be_empty
    end

    it 'does not enter lines consisting of only whitespace into the history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type("\n   \n")
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to be_empty
    end

    it 'does not enter nil lines into the history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.send_eof
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to be_empty
    end

    it 'does not #pop the last entry to history if add_hist is false' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_history_filter.readline('>', true)
      fake_readline.type(' ')
      readline_history_filter.readline('>', false)

      expect(readline_history_filter::HISTORY.to_a).to eq(['hello'])
    end

    it 'does not enter duplicate sequential history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_history_filter.readline('>', true)
      fake_readline.type('hello')
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to eq(['hello'])
    end

    it 'enters non-sequential duplicate lines into the history' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_history_filter.readline('>', true)
      fake_readline.type('test')
      readline_history_filter.readline('>', true)
      fake_readline.type('hello')
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).
        to eq(['hello', 'test', 'hello'])
    end

    it 'does not enter duplicate history with whitespace inbetween' do
      readline_history_filter = ReadlineHistoryFilter.new(fake_readline)

      fake_readline.type('hello')
      readline_history_filter.readline('>', true)
      fake_readline.type('')
      readline_history_filter.readline('>', true)
      fake_readline.type('hello')
      readline_history_filter.readline('>', true)

      expect(readline_history_filter::HISTORY.to_a).to eq(['hello'])
    end
  end
end
