require 'spec_helper'
require 'gitsh/git_command'

describe Gitsh::GitCommand do
  let(:env) do
    stub('Environment', {
      git_command: '/usr/bin/env git',
      output_stream: stub(to_i: 1),
      error_stream: stub(to_i: 2)
    })
  end

  before { Process.stubs(spawn: 1, wait: nil) }

  describe '#execute' do
    it 'spawns a process with the sub command and arguments' do
      env.stubs(config_variables: {})
      command = described_class.new(env, 'commit', ['-m', 'A test commit'])

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
      env.stubs(config_variables: {
        :'test.example' => 'This is an example',
        :'foo.bar' => '1'
      })
      command = described_class.new(env, 'commit', ['-m', 'A test commit'])

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
