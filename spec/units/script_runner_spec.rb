require 'spec_helper'
require 'stringio'
require 'gitsh/script_runner'

describe Gitsh::ScriptRunner do
  describe '#run' do
    it 'passes each command to the interpreter' do
      script = temp_file('script', "commit -m 'Changes'\npush -f")
      interpreter = spy('Interpreter', execute: nil)
      runner = described_class.new(interpreter: interpreter)

      runner.run script.path

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with("commit -m 'Changes'\n")
      expect(interpreter).to have_received(:execute).with("push -f\n")
    end

    context 'with -' do
      it 'reads commands from STDIN' do
        input_stream = StringIO.new("push\npull\n")
        env = double('Environment', input_stream: input_stream)
        interpreter = spy('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        runner.run '-'

        expect(interpreter).to have_received(:execute).twice
        expect(interpreter).to have_received(:execute).with("push\n")
        expect(interpreter).to have_received(:execute).with("pull\n")
      end
    end

    context 'with a file that does not exist' do
      it 'raises a NoInputError' do
        env = double('Environment')
        interpreter = double('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        expect { runner.run 'no/such/script' }.to raise_exception(
          Gitsh::NoInputError,
          /No such file/,
        )
      end
    end

    context 'with a file that the current user cannot read' do
      it 'raises a NoInputError' do
        script = temp_file('script', "commit -m 'Changes'\npush -f")
        allow(File).to receive(:open).and_raise(Errno::EACCES)
        env = double('Environment')
        interpreter = double('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        expect { runner.run script.path }.to raise_exception(
          Gitsh::NoInputError,
          /Permission denied/,
        )
      end
    end
  end
end
