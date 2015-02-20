require 'spec_helper'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::ShellCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(:env)
      expected_result = double(:result)
      mock_runner = double(:shell_command_runner, run: expected_result)

      command = described_class.new(
        env,
        "echo",
        arguments("Hello", "world"),
        shell_command_runner: mock_runner,
      )
      result = command.execute

      expect(mock_runner).to have_received(:run).with(
        ["echo", "Hello", "world"],
        env,
      )
      expect(result).to eq expected_result
    end
  end
end
