require 'spec_helper'
require 'stringio'
require 'gitsh/script_runner'

describe Gitsh::ScriptRunner do
  describe '#run' do
    it 'passes each command to the interpreter' do
      script = temp_file('script', "commit -m 'Changes'\npush -f")
      interpreter = stub('Interpreter', execute: nil)
      runner = described_class.new(interpreter: interpreter)

      runner.run script.path

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with("commit -m 'Changes'\n")
      expect(interpreter).to have_received(:execute).with("push -f\n")
    end

    context 'with -' do
      it 'reads commands from STDIN' do
        input_stream = StringIO.new("push\npull\n")
        env = stub('Environment', input_stream: input_stream)
        interpreter = stub('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        runner.run '-'

        expect(interpreter).to have_received(:execute).twice
        expect(interpreter).to have_received(:execute).with("push\n")
        expect(interpreter).to have_received(:execute).with("pull\n")
      end
    end

    context 'with a file that does not exist' do
      it 'exits' do
        env = stub('Environment', puts_error: nil)
        interpreter = stub('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        expect { runner.run 'no/such/script' }.to raise_exception(SystemExit)
        expect(env).to have_received(:puts_error)
      end
    end

    context 'with a file that the current user cannot read' do
      it 'exits' do
        script = temp_file('script', "commit -m 'Changes'\npush -f")
        File.stubs(:open).raises(Errno::EACCES)
        env = stub('Environment', puts_error: nil)
        interpreter = stub('Interpreter', execute: nil)
        runner = described_class.new(env: env, interpreter: interpreter)

        expect { runner.run script.path }.to raise_exception(SystemExit)
        expect(env).to have_received(:puts_error)
      end
    end
  end
end
