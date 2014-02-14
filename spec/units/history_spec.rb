require 'spec_helper'
require 'gitsh/history'

describe Gitsh::History do
  before do
    @history_file = Tempfile.new('history')
  end

  after do
    @history_file.close
    @history_file.unlink
  end

  let(:env) { { 'gitsh.historyFile' => @history_file.path } }
  let(:readline) do
    Class.new.tap { |readline| readline::HISTORY = [] }
  end

  describe '#load' do
    it 'adds the saved history to Readline' do
      write_history_file ['init', 'add -p', 'commit']

      described_class.new(env, readline).load

      expect(readline::HISTORY).to eq ['init', 'add -p', 'commit']
    end

    it 'does nothing when the history file does not exist' do
      history = described_class.new(env, readline)
      @history_file.close
      @history_file.unlink

      history.load

      expect(readline::HISTORY).to be_empty
    end
  end

  describe '#save' do
    it 'saves the history from Readline to disk' do
      readline::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])

      described_class.new(env, readline).save

      expect(history_file_lines).to eq [
        "init\n", "add .\n", "commit -m \"Initial\"\n"
      ]
    end

    it 'is limited by the gitsh.historySize setting' do
      readline::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])
      env['gitsh.historySize'] = 2

      described_class.new(env, readline).save

      expect(history_file_lines).to eq [
        "add .\n", "commit -m \"Initial\"\n"
      ]
    end
  end

  def write_history_file(commands)
    commands.each do |command|
      @history_file.write("#{command}\n")
    end
    @history_file.rewind
  end

  def history_file_lines
    @history_file.each_line.to_a
  end
end
