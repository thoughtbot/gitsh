require 'spec_helper'
require 'stringio'
require 'gitsh/input_strategies/file'

describe Gitsh::InputStrategies::File do
  describe '#setup' do
    context 'with a file that does not exist' do
      it 'raises a NoInputError' do
        input_strategy = described_class.new(
          path: 'no/such/script',
        )

        expect { input_strategy.setup }.to raise_exception(
          Gitsh::NoInputError,
          /No such file/,
        )
      end
    end

    context 'with a file that the current user cannot read' do
      it 'raises a NoInputError' do
        script = temp_file('script', "commit -m 'Changes'\npush -f")
        allow(File).to receive(:open).and_raise(Errno::EACCES)
        input_strategy = described_class.new(path: script.path)

        expect { input_strategy.setup }.to raise_exception(
          Gitsh::NoInputError,
          /Permission denied/,
        )
      end
    end
  end

  describe '#teardown' do
    it 'closes the file' do
      file = double(:file, close: nil)
      allow(File).to receive(:open).with('my_script.gitsh').and_return(file)
      input_strategy = described_class.new(path: 'my_script.gitsh')
      input_strategy.setup

      input_strategy.teardown

      expect(file).to have_received(:close)
    end
  end

  describe '#read_command' do
    it 'returns each line of the file followed by a nil' do
      script = temp_file('script', "commit -m 'Changes'\npush -f")
      input_strategy = described_class.new(path: script.path)
      input_strategy.setup

      expect(input_strategy.read_command).to eq 'commit -m \'Changes\''
      expect(input_strategy.read_command).to eq 'push -f'
      expect(input_strategy.read_command).to be_nil
    end

    context 'with -' do
      it 'reads each line from STDIN' do
        input_stream = StringIO.new("push\npull\n")
        register_env(input_stream: input_stream)
        input_strategy = described_class.new(path: '-')
        input_strategy.setup

        expect(input_strategy.read_command).to eq 'push'
        expect(input_strategy.read_command).to eq 'pull'
        expect(input_strategy.read_command).to be_nil
      end
    end
  end

  describe '#read_continuation' do
    it 'returns the next line of the file' do
      script = temp_file('script', "commit -m 'Changes'\npush -f")
      input_strategy = described_class.new(
        path: script.path,
      )
      input_strategy.setup
      input_strategy.read_command

      expect(input_strategy.read_continuation).to eq 'push -f'
    end

    context 'with no lines left to return' do
      it 'raises' do
        script = temp_file('script', 'commit -m \'Changes\'')
        input_strategy = described_class.new(
          path: script.path,
        )
        input_strategy.setup
        input_strategy.read_command

        expect { input_strategy.read_continuation }.to raise_exception(EOFError)
      end
    end
  end

  describe '#handle_parse_error' do
    it 'raises' do
      input_strategy = described_class.new(path: double)

      expect { input_strategy.handle_parse_error('my message') }.
        to raise_exception(Gitsh::ParseError, 'my message')
    end
  end
end
