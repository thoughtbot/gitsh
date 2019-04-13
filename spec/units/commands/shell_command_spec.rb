require 'spec_helper'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::ShellCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(:env)
      expected_result = double(:result)
      stub_shell_command_runner(expected_result)

      command = described_class.new(
        'echo',
        ['Hello', 'world'],
      )
      result = command.execute(env)

      expect(Gitsh::ShellCommandRunner).to have_received(:run).with(
        ['/bin/sh', '-c', 'echo Hello world'],
        env,
      )
      expect(result).to eq expected_result
    end

    it 'escapes special characters in arguments' do
      env = double(:env)
      stub_shell_command_runner
      args = ['with space', '^$']
      escaped_args = ['with\\ space', '\\^\\$']

      described_class.
        new('echo', args).
        execute(env)

      expect(Gitsh::ShellCommandRunner).to have_received(:run).with(
        ['/bin/sh', '-c', "echo #{escaped_args.join(' ')}"],
        env,
      )
    end

    it 'does not escape globbing patterns in arguments' do
      env = double(:env)
      stub_shell_command_runner
      args = ['*', '[a-z]', '[!a-z]', '?', '\\*']

      described_class.
        new('echo', args).
        execute(env)

      expect(Gitsh::ShellCommandRunner).to have_received(:run).with(
        ['/bin/sh', '-c', "echo #{args.join(' ')}"],
        env,
      )
    end
  end

  def stub_shell_command_runner(result = true)
    allow(Gitsh::ShellCommandRunner).to receive(:run).and_return(result)
  end
end
