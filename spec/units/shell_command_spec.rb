require 'spec_helper'
require 'gitsh/shell_command'

describe Gitsh::ShellCommand do
  describe '#execute' do
    before do
      Process.stubs(spawn: 1, wait: nil, kill: nil)
      ensure_exit_status_exists
    end

    it 'spawns a process with the command and arguments' do
      command = described_class.new(env, 'echo', ['Hello world'])

      command.execute

      expect(Process).to have_received(:spawn).with(
        'echo', 'Hello world',
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end

    it 'returns true when the shell command succeeds' do
      $?.stubs(success?: true)
      command = described_class.new(env, 'echo', ['Hello world'])

      expect(command.execute).to eq true
    end

    it 'returns false when the shell command fails' do
      $?.stubs(success?: false)
      command = described_class.new(env, 'badcommand', ['Hello world'])

      expect(command.execute).to eq false
    end

    it 'returns false when Process.spawn raises' do
      Process.stubs(:spawn).raises(Errno::ENOENT, 'No such file')
      command = described_class.new(env, 'badcommand', ['Hello world'])

      expect(command.execute).to eq false
    end

    it 'forwards interrupts to the child process' do
      pid = 12
      Process.stubs(:spawn).returns(pid)
      Process.stubs(:wait).with(pid).raises(Interrupt).then.returns(nil)
      command = described_class.new(env, 'vim', [])

      command.execute

      expect(Process).to have_received(:wait).with(pid).twice
      expect(Process).to have_received(:kill).with('INT', pid).once
    end
  end

  def ensure_exit_status_exists
    `pwd`
    expect($?).not_to be_nil
  end

  let(:env) do
    stub('Environment',
      output_stream: stub(to_i: 1),
      error_stream: stub(to_i: 2),
      puts_error: nil
    )
  end
end
