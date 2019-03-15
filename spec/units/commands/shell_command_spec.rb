require 'spec_helper'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::ShellCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(:env)
      expected_result = double(:result)
      mock_runner = double(:shell_command_runner, run: expected_result)

      command = described_class.new(
        'echo',
        ['Hello', 'world'],
        shell_command_runner: mock_runner,
      )
      result = command.execute(env)

      expect(mock_runner).to have_received(:run).with(
        ['/bin/sh', '-c', 'echo Hello world'],
        env,
      )
      expect(result).to eq expected_result
    end

    it 'escapes special characters in arguments' do
      env = double(:env)
      mock_runner = double(:shell_command_runner, run: double(:result))
      args = ['with space', '^$']
      escaped_args = ['with\\ space', '\\^\\$']

      described_class.
        new('echo', args, shell_command_runner: mock_runner).
        execute(env)

      expect(mock_runner).to have_received(:run).with(
        ['/bin/sh', '-c', "echo #{escaped_args.join(' ')}"],
        env,
      )
    end

    it 'does not escape globbing patterns in arguments' do
      env = double(:env)
      mock_runner = double(:shell_command_runner, run: double(:result))
      args = ['*', '[a-z]', '[!a-z]', '?', '\\*']

      described_class.
        new('echo', args, shell_command_runner: mock_runner).
        execute(env)

      expect(mock_runner).to have_received(:run).with(
        ['/bin/sh', '-c', "echo #{args.join(' ')}"],
        env,
      )
    end
  end
end
