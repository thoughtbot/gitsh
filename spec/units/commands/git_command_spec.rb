require 'spec_helper'
require 'gitsh/commands/git_command'

describe Gitsh::Commands::GitCommand do
  let(:env) do
    double('Environment', {
      git_command: '/usr/bin/env git',
      output_stream: double('OutputStream', to_i: 1),
      error_stream: double('ErrorStream', to_i: 2)
    })
  end

  before do
    allow(Process).to receive(:spawn).and_return(1)
    allow(Process).to receive(:wait)
  end

  describe '#execute' do
    it 'spawns a process with the sub command and arguments' do
      allow(env).to receive(:config_variables).and_return({})
      command = described_class.new(
        env,
        'commit',
        arguments('-m', 'A test commit'),
      )

      command.execute

      expect(Process).to have_received(:spawn).with(
        '/usr/bin/env', 'git',
        'commit',
        '-m', 'A test commit',
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end

    it 'passes on configuration variables from the environment' do
      allow(env).to receive(:config_variables).and_return(
        :'test.example' => 'This is an example',
        :'foo.bar' => '1'
      )
      command = described_class.new(
        env,
        'commit',
        arguments('-m', 'A test commit'),
        shell_command_runner: mock_runner,
      )

      command.execute

      expect(Process).to have_received(:spawn).with(
        '/usr/bin/env', 'git',
        '-c', 'test.example=This is an example',
        '-c', 'foo.bar=1',
        'commit',
        '-m', 'A test commit',
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end
  end
end
