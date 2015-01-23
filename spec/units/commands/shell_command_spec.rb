require 'spec_helper'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::ShellCommand do
  describe '#execute' do
    before do
      allow(Process).to receive(:spawn).and_return(1)
      allow(Process).to receive(:wait)
      allow(Process).to receive(:kill)
      ensure_exit_status_exists
    end

    it 'spawns a process with the command and arguments' do
      command = described_class.new(env, 'echo', arguments('Hello world'))

      command.execute

      expect(Process).to have_received(:spawn).with(
        'echo', 'Hello world',
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end

    it 'returns true when the shell command succeeds' do
      allow($?).to receive(:success?).and_return(true)
      command = described_class.new(env, 'echo', arguments('Hello world'))

      expect(command.execute).to eq true
    end

    it 'returns false when the shell command fails' do
      allow($?).to receive(:success?).and_return(false)
      command = described_class.new(env, 'badcommand', arguments('Hello world'))

      expect(command.execute).to eq false
    end

    it 'returns false when Process.spawn raises' do
      allow(Process).to receive(:spawn).and_raise(Errno::ENOENT, 'No such file')
      command = described_class.new(env, 'badcommand', arguments('Hello world'))

      expect(command.execute).to eq false
    end

    it 'forwards interrupts to the child process' do
      pid = 12
      wait_results = StubbedMethodResult.new.
        raises(Interrupt).
        returns(nil)
      allow(Process).to receive(:spawn).and_return(pid)
      allow(Process).to receive(:wait).with(pid) { wait_results.next_result }
      command = described_class.new(env, 'vim', arguments())

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
    double('Environment',
      output_stream: double('OutputStream', to_i: 1),
      error_stream: double('ErrorStream', to_i: 2),
      puts_error: nil
    )
  end
end
