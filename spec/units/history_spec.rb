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

  before do
    register_env
    set_env_value('gitsh.historyFile', @history_file.path)
    set_env_value('gitsh.historySize', described_class::DEFAULT_HISTORY_SIZE)
  end

  let(:line_editor) {
    Class.new.tap { |line_editor| line_editor::HISTORY = [] }
  }

  describe '#load' do
    it 'adds the saved history to the line editor' do
      write_history_file ['init', 'add -p', 'commit']

      described_class.new(line_editor).load

      expect(line_editor::HISTORY).to eq ['init', 'add -p', 'commit']
    end

    it 'does nothing when the history file does not exist' do
      history = described_class.new(line_editor)
      @history_file.close
      @history_file.unlink

      history.load

      expect(line_editor::HISTORY).to be_empty
    end
  end

  describe '#save' do
    it 'saves the history from the line editor to disk' do
      line_editor::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])

      described_class.new(line_editor).save

      expect(history_file_lines).to eq [
        "init\n", "add .\n", "commit -m \"Initial\"\n"
      ]
    end

    it 'is limited by the gitsh.historySize setting' do
      line_editor::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])
      set_env_value('gitsh.historySize', 2)

      described_class.new(line_editor).save

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

  def set_env_value(key, value)
    allow(Gitsh::Registry.env).to receive(:fetch).with(key).and_return(value)
  end
end
