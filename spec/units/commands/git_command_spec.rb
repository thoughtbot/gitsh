require 'spec_helper'
require 'gitsh/commands/git_command'

describe Gitsh::Commands::GitCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(
        :env,
        git_command: '/usr/bin/env git',
        config_variables: {},
        fetch: nil,
      )
      expected_result = double(:result)
      mock_runner = double(:shell_command_runner, run: expected_result)

      command = described_class.new(
        "commit",
        ['-m', 'Some stuff'],
        shell_command_runner: mock_runner,
      )
      result = command.execute(env)

      expect(mock_runner).to have_received(:run).with(
        ["/usr/bin/env", "git", "commit", "-m", "Some stuff"],
        env,
      )
      expect(result).to eq expected_result
    end

    it 'passes on configuration variables from the environment' do
      mock_runner = double(:shell_command_runner, run: true)
      env = double(
        :env,
        git_command: '/usr/bin/env git',
        config_variables: {
          :'test.example' => 'This is an example',
          :'foo.bar' => '1',
        },
        fetch: nil,
      )
      command = described_class.new(
        'commit',
        ['-m', 'A test commit'],
        shell_command_runner: mock_runner,
      )

      command.execute(env)

      expect(mock_runner).to have_received(:run).with(
        [
          '/usr/bin/env', 'git',
          '-c', 'test.example=This is an example',
          '-c', 'foo.bar=1',
          'commit',
          '-m', 'A test commit',
        ],
        env,
      )
    end

    context 'with autocorrect enabled' do
      it 'removes a "git" prefix' do
        env = double(
          :env,
          git_command: '/usr/bin/env git',
          config_variables: {foo: '1'},
        )
        mock_runner = double(:shell_command_runner, run: double)
        allow(env).to receive(:fetch).with('help.autocorrect').and_return('1')

        command = described_class.new(
          "git",
          ['commit', '-m', 'Some stuff'],
          shell_command_runner: mock_runner,
        )
        command.execute(env)

        expect(mock_runner).to have_received(:run).with(
          ["/usr/bin/env", "git", "-c", "foo=1", "commit", "-m", "Some stuff"],
          env,
        )
      end
    end

    context 'with autocorrect disabled' do
      it 'does not remove a "git" prefix' do
        env = double(
          :env,
          git_command: '/usr/bin/env git',
          config_variables: {},
        )
        mock_runner = double(:shell_command_runner, run: double)
        allow(env).to receive(:fetch).with('help.autocorrect').and_return('0')

        command = described_class.new(
          "git",
          ['commit', '-m', 'Some stuff'],
          shell_command_runner: mock_runner,
        )
        command.execute(env)

        expect(mock_runner).to have_received(:run).with(
          ["/usr/bin/env", "git", "git", "commit", "-m", "Some stuff"],
          env,
        )
      end
    end
  end
end
