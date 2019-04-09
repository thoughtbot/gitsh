require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
    context 'with valid arguments and no script file' do
      it 'uses the interactive input strategy' do
        register_env
        interpreter = stub_interpreter
        interactive_input_strategy = stub_interactive_input_strategy
        cli = Gitsh::CLI.new([])

        cli.run

        expect(interpreter).to have_received(:run)
        expect(Gitsh::Interpreter).to have_received(:new).
          with(hash_including(input_strategy: interactive_input_strategy))
      end
    end

    context 'when STDIN is not a TTY' do
      it 'calls the script runner with -' do
        register_env(tty?: false)
        interpreter = stub_interpreter
        file_input_strategy = stub_file_input_strategy
        cli = Gitsh::CLI.new([])

        cli.run

        expect(Gitsh::InputStrategies::File).to have_received(:new).
          with(hash_including(path: '-'))
        expect(Gitsh::Interpreter).to have_received(:new).
          with(hash_including(input_strategy: file_input_strategy))
        expect(interpreter).to have_received(:run)
      end
    end

    context 'with a script file' do
      it 'calls the script runner with the script file' do
        register_env
        interpreter = stub_interpreter
        file_input_strategy = stub_file_input_strategy
        cli = Gitsh::CLI.new(['path/to/a/script'])

        cli.run

        expect(Gitsh::InputStrategies::File).to have_received(:new).
          with(hash_including(path: 'path/to/a/script'))
        expect(Gitsh::Interpreter).to have_received(:new).
          with(hash_including(input_strategy: file_input_strategy))
        expect(interpreter).to have_received(:run)
      end
    end

    context 'with an unreadable script file' do
      it 'exits' do
        register_env
        interpreter = stub_interpreter
        allow(interpreter).to receive(:run).
          and_raise(Gitsh::NoInputError, 'Oh no!')
        cli = Gitsh::CLI.new(['path/to/a/script'])

        expect { cli.run }.to raise_exception(SystemExit)
        expect(Gitsh::Registry.env).
          to have_received(:puts_error).with('gitsh: Oh no!')
      end
    end

    context 'with invalid arguments' do
      it 'exits with a usage message' do
        register_env
        cli = Gitsh::CLI.new(['--bad-argument'])

        expect { cli.run }.to raise_exception(SystemExit)
      end
    end

    context 'with a non-existent git' do
      it 'exits with a helpful error message' do
        register_env(git_command: 'nonexistent')
        cli = Gitsh::CLI.new([])

        expect { cli.run }.to raise_exception(SystemExit)
        expect(Gitsh::Registry.env).to have_received(:puts_error).with(
          "gitsh: nonexistent: No such file or directory\nEnsure git is on "\
          'your PATH, or specify the path to git using the --git option',
        )
      end
    end

    context 'with a non-executable git' do
      it 'exits with a helpful error message' do
        non_executable = Tempfile.new('git')
        non_executable.close
        begin
          register_env(git_command: non_executable.path)
          cli = Gitsh::CLI.new([])

          expect { cli.run }.to raise_exception(SystemExit)
          expect(Gitsh::Registry.env).to have_received(:puts_error).with(
            "gitsh: #{non_executable.path}: Permission denied\nEnsure git is "\
            'executable',
          )
        ensure
          non_executable.unlink
        end
      end
    end
  end

  def stub_interpreter
    interpreter = double('Interpreter', run: nil)
    allow(Gitsh::Interpreter).to receive(:new).and_return(interpreter)
    interpreter
  end

  def stub_interactive_input_strategy
    input_strategy = double('InputStrategies::Interactive', run: nil)
    allow(Gitsh::InputStrategies::Interactive).to receive(:new).
      and_return(input_strategy)
    input_strategy
  end

  def stub_file_input_strategy
    input_strategy = double('InputStrategies::File', run: nil)
    allow(Gitsh::InputStrategies::File).to receive(:new).
      and_return(input_strategy)
    input_strategy
  end
end
