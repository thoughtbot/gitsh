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
    set_registered_env_value('gitsh.historyFile', @history_file.path)
    set_registered_env_value(
      'gitsh.historySize',
      described_class::DEFAULT_HISTORY_SIZE,
    )
  end

  describe '#load' do
    it 'adds the saved history to the line editor' do
      line_editor = register_line_editor
      write_history_file ['init', 'add -p', 'commit']

      described_class.new.load

      expect(line_editor::HISTORY).to eq ['init', 'add -p', 'commit']
    end

    it 'does nothing when the history file does not exist' do
      line_editor = register_line_editor
      history = described_class.new
      @history_file.close
      @history_file.unlink

      history.load

      expect(line_editor::HISTORY).to be_empty
    end
  end

  describe '#save' do
    it 'saves the history from the line editor to disk' do
      line_editor = register_line_editor
      line_editor::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])

      described_class.new.save

      expect(history_file_lines).to eq [
        "init\n", "add .\n", "commit -m \"Initial\"\n"
      ]
    end

    it 'is limited by the gitsh.historySize setting' do
      line_editor = register_line_editor
      line_editor::HISTORY.concat(['init', 'add .', 'commit -m "Initial"'])
      set_registered_env_value('gitsh.historySize', 2)

      described_class.new.save

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
