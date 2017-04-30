require 'spec_helper'
require 'gitsh/environment'

describe Gitsh::Environment do
  describe '#[]=' do
    it 'sets a gitsh environment variable' do
      repository = double('GitRepository', config: nil)
      factory = double('RepositoryFactory', new: repository)
      env = described_class.new(repository_factory: factory)

      env['foo'] = 'bar'
      expect(env.fetch('foo')).to eq 'bar'
    end
  end

  describe '#fetch' do
    context 'for a magic variable' do
      it 'returns the value of the magic variable' do
        magic_variables = double(:magic_variables)
        allow(magic_variables).to receive(:fetch).with(:_prior).
          and_return('a-branch-name')
        env = described_class.new(magic_variables: magic_variables)

        expect(env.fetch(:_prior)).to eq 'a-branch-name'
        expect(env.fetch('_prior')).to eq 'a-branch-name'
      end
    end

    context 'for a gitsh environment variable' do
      it 'returns the value of the environment variable' do
        env = described_class.new
        env[:foo] = 'bar'

        expect(env.fetch(:foo)).to eq 'bar'
        expect(env.fetch('foo')).to eq 'bar'
      end
    end

    context 'for a Git configuration variable' do
      it 'returns the value of the Git configuration variable' do
        repository = double('GitRepository')
        allow(repository).to receive(:config).with('user.name', false).
          and_return('John Smith')
        factory = double('RepositoryFactory', new: repository)
        env = described_class.new(repository_factory: factory)

        expect(env.fetch(:'user.name')).to eq 'John Smith'
        expect(env.fetch('user.name')).to eq 'John Smith'
      end
    end

    context 'for an unknown variable with a default block given' do
      it 'yields to the block' do
        env = described_class.new

        expect(env.fetch(:unknown) { 'default' }).to eq 'default'
      end
    end

    context 'for an unknown variable with no default block given' do
      it 'raises an error' do
        env = described_class.new

        expect { env.fetch(:unknown) }.
          to raise_exception(Gitsh::UnsetVariableError, /unknown/)
      end
    end
  end

  describe '#available_variables' do
    it 'returns the names of all available variables' do
      repository = double('GitRepository')
      allow(repository).to receive(:available_config_variables).
        and_return([:'user.name'])
      factory = double('RepositoryFactory', new: repository)
      magic_variables = double('MagicVariables')
      allow(magic_variables).to receive(:available_variables).
        and_return([:_prior])
      env = described_class.new(
        magic_variables: magic_variables,
        repository_factory: factory,
      )
      env[:foo] = 'bar'
      env['user.name'] = 'Config Override'

      expect(env.available_variables).to eq [
        :_prior,
        :foo,
        :'user.name',
      ]
    end
  end

  describe '#clone' do
    it 'creates a copy with an isolated set of variables' do
      original = described_class.new
      original['a'] = 'A is set'

      copy = original.clone
      copy['b'] = 'B is set'

      expect(original.fetch('a')).to eq 'A is set'
      expect(copy.fetch('a')).to eq 'A is set'
      expect { original.fetch('b') }.to raise_exception(Gitsh::Error)
      expect(copy.fetch('b')).to eq 'B is set'
    end
  end

  describe '#config_variables' do
    it 'returns variables that have a dot in the name' do
      env = described_class.new
      env['example'] = '1'
      env['user.name'] = 'Joe Bloggs'
      env['user.email'] = 'joe@example.com'

      expect(env.config_variables).to eq(
        :'user.name' => 'Joe Bloggs',
        :'user.email' => 'joe@example.com'
      )
    end
  end

  describe '#input_stream' do
    it 'returns $stdin by default' do
      env = described_class.new

      expect(env.input_stream).to eq $stdin
    end

    it 'returns the input stream passed to the constructor' do
      stream = double
      env = described_class.new(input_stream: stream)

      expect(env.input_stream).to eq stream
    end
  end

  describe '#output_stream' do
    it 'returns $stdout by default' do
      env = described_class.new

      expect(env.output_stream).to eq $stdout
    end

    it 'returns the output stream passed to the constructor' do
      stream = double
      env = described_class.new(output_stream: stream)

      expect(env.output_stream).to eq stream
    end
  end

  describe '#git_command' do
    it 'defaults to "/usr/bin/env git"' do
      with_a_temporary_home_directory do
        env = described_class.new

        expect(env.git_command).to eq '/usr/bin/env git'
      end
    end

    it 'defaults to gitsh.gitCommand if present' do
      env = described_class.new
      env['gitsh.gitCommand'] = '/path/to/git'

      expect(env.git_command).to eq '/path/to/git'
    end

    it 'can be overridden' do
      env = described_class.new
      env.git_command = '/path/to/git'

      expect(env.git_command).to eq '/path/to/git'
    end
  end

  describe '#print' do
    it 'prints to the output stream' do
      output = StringIO.new
      env = described_class.new(output_stream: output)

      env.print 'Hello world'

      expect(output.string).to eq 'Hello world'
    end
  end

  describe '#puts' do
    it 'prints to the output stream' do
      output = StringIO.new
      env = described_class.new(output_stream: output)

      env.puts 'Hello world'

      expect(output.string).to eq "Hello world\n"
    end
  end

  describe '#puts_error' do
    it 'prints to the error stream' do
      error = StringIO.new
      env = described_class.new(error_stream: error)

      env.puts_error 'Oh no!'

      expect(error.string).to eq "Oh no!\n"
    end
  end

  describe '#tty?' do
    it 'returns true when the input stream is a TTY' do
      input = double('STDIN', tty?: true)
      env = described_class.new(input_stream: input)

      expect(env).to be_tty
    end

    it 'returns false when the input stream is not a TTY' do
      input = double('STDIN', tty?: false)
      env = described_class.new(input_stream: input)

      expect(env).not_to be_tty
    end
  end

  describe '#git_aliases' do
    it 'combines locally-set aliases with global aliases' do
      repo = double('GitRepository', aliases: %w( foo bar ))
      env = described_class.new(repository_factory: double(new: repo))
      env['aliasish'] = 'not relevant'
      env['alias.baz'] = '!echo baz'

      expect(env.git_aliases).to eq %w( foo bar baz ).sort
    end
  end

  context 'delegated methods' do
    let(:repo) { double }
    let(:repo_factory) { double('RepositoryFactory', new: repo) }
    let(:env) { described_class.new(repository_factory: repo_factory) }

    describe '#repo_heads' do
      it 'is delegated to the GitRepository' do
        expect(env).to delegate(:repo_heads).to(repo, :heads)
      end
    end

    describe '#repo_current_head' do
      it 'is delegated to the GitRepository' do
        expect(env).to delegate(:repo_current_head).to(repo, :current_head)
      end
    end

    describe '#repo_status' do
      it 'is delegated to the GitRepository' do
        expect(env).to delegate(:repo_status).to(repo, :status)
      end
    end

    describe '#git_commands' do
      it 'is delegated to the GitRepository' do
        expect(env).to delegate(:git_commands).to(repo, :commands)
      end
    end

    describe '#repo_config_color' do
      context 'when there is no environment variable set' do
        it 'gets the color setting from the repo' do
          expected_color = double('color')
          repo = double('GitRepository', config_color: expected_color, config: nil)
          env = described_class.new(repository_factory: double(new: repo))

          color = env.repo_config_color('test.color.foo', 'red')

          expect(color).to eq expected_color
          expect(repo).to have_received(:config_color).
            with('test.color.foo', 'red')
        end
      end

      context 'when there is an environment variable set' do
        it 'gets the repo to convert the color to an ANSI escape sequence' do
          expected_color = double('color')
          repo = double('GitRepository', color: expected_color, config: nil)
          env = described_class.new(repository_factory: double(new: repo))

          env['test.color.foo'] = 'blue'
          color = env.repo_config_color('test.color.foo', 'red')

          expect(color).to eq expected_color
          expect(repo).to have_received(:color).with('blue')
        end
      end
    end
  end
end
