require 'spec_helper'
require 'gitsh/git_command'

describe Gitsh::GitCommand do
  let(:env) do
    stub('Environment', {
      git_command: '/usr/bin/env git',
      output_stream: stub,
      error_stream: stub
    })
  end

  before { Process.stubs(spawn: 1, wait: nil) }

  describe '#execute' do
    it 'spawns a process with the sub command and arguments' do
      command = described_class.new(env, 'commit', ['-m', 'A test commit'])

      command.execute

      expect(Process).to have_received(:spawn).with(
        '/usr/bin/env', 'git',
        'commit',
        '-m', 'A test commit',
        out: env.output_stream,
        err: env.error_stream
      )
    end
  end
end
