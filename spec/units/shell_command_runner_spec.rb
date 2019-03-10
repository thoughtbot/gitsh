require 'spec_helper'
require 'gitsh/shell_command_runner'

describe Gitsh::ShellCommandRunner do
  describe '#run' do
    before do
      allow(Process).to receive(:spawn).and_return(1)
      allow(Process).to receive(:wait)
      allow(Process).to receive(:kill)
      ensure_exit_status_exists
    end

    it 'spawns a process with the command and arguments' do
      runner = described_class.new(["echo", "Hello world"], env)

      runner.run

      expect(Process).to have_received(:spawn).with(
        'echo', 'Hello world',
        in: env.input_stream.to_i,
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end

    it 'returns true when the shell command succeeds' do
      allow($?).to receive(:success?).and_return(true)
      runner = described_class.new(['goodcommand'], env)

      expect(runner.run).to eq true
    end

    it 'returns false when the shell command fails' do
      allow($?).to receive(:success?).and_return(false)
      runner = described_class.new(['badcommand'], env)

      expect(runner.run).to eq false
    end

    it 'returns false when Process.spawn raises' do
      allow(Process).to receive(:spawn).and_raise(Errno::ENOENT, 'No such file')
      runner = described_class.new(['badcommand'], env)

      expect(runner.run).to eq false
    end

    it 'forwards interrupts to the child process' do
      pid = 12
      wait_results = StubbedMethodResult.new.
        raises(Interrupt).
        returns(nil)
      allow(Process).to receive(:spawn).and_return(pid)
      allow(Process).to receive(:wait).with(pid) { wait_results.next_result }
      runner = described_class.new(["vim"], env)

      runner.run

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
      input_stream: double('InputStream', to_i: 0),
      output_stream: double('OutputStream', to_i: 1),
      error_stream: double('ErrorStream', to_i: 2),
      puts_error: nil
    )
  end
end
