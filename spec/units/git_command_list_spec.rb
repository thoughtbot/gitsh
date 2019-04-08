require 'spec_helper'
require 'gitsh/git_command_list'

describe Gitsh::GitCommandList do
  GIT_COMMAND = '/usr/bin/env git'.freeze
  MODERN_LIST_COMMAND = "#{GIT_COMMAND} --list-cmds=main,nohelpers".freeze
  MODERN_HELP_COMMAND = "#{GIT_COMMAND} help -a --no-verbose".freeze
  LEGACY_HELP_COMMAND = "#{GIT_COMMAND} help -a".freeze

  before { register_env(git_command: GIT_COMMAND) }

  describe '#to_a' do
    it 'produces the list of porcelain commands' do
      commands = Gitsh::GitCommandList.new.to_a

      expect(commands).to include %(add)
      expect(commands).to include %(commit)
      expect(commands).to include %(checkout)
      expect(commands).to include %(status)
      expect(commands).not_to include %(add--interactive)
      expect(commands).not_to include ''
    end

    context 'with a Git version that supports --list-cmds' do
      it 'uses that command list' do
        stub_command(MODERN_LIST_COMMAND, output: "commit\nstatus\nadd\n")

        commands = Gitsh::GitCommandList.new.to_a

        expect(commands).to eq ['add', 'commit', 'status']
      end
    end

    context 'with a Git version that supports `help --no-verbose`' do
      it 'parses the help output' do
        stub_command(MODERN_LIST_COMMAND, success: false)
        stub_command(
          MODERN_HELP_COMMAND,
          output: "Commands:\n  commit   status\n  add\n",
        )

        commands = Gitsh::GitCommandList.new.to_a

        expect(commands).to eq ['add', 'commit', 'status']
      end
    end

    context 'with an old Git version' do
      it 'parses the help output' do
        stub_command(MODERN_LIST_COMMAND, success: false)
        stub_command(MODERN_HELP_COMMAND, success: false)
        stub_command(
          LEGACY_HELP_COMMAND,
          output: "Commands:\n  commit   status\n  add\n",
        )

        commands = Gitsh::GitCommandList.new.to_a

        expect(commands).to eq ['add', 'commit', 'status']
      end
    end

    context 'when nothing we try works' do
      it 'returns an empty array' do
        stub_command(MODERN_LIST_COMMAND, success: false)
        stub_command(MODERN_HELP_COMMAND, success: false)
        stub_command(LEGACY_HELP_COMMAND, success: false)

        commands = Gitsh::GitCommandList.new.to_a

        expect(commands).to eq []
      end
    end
  end

  def stub_command(command, success: true, output: '')
    status = instance_double(Process::Status, success?: success)
    allow(Open3).to receive(:capture3).with(command).
      and_return([output, '', status])
  end
end
