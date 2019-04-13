require 'spec_helper'
require 'gitsh/environment'

describe Gitsh::Environment do
  before { register_repo }

  describe '#[]=' do
    it 'sets a gitsh environment variable' do
      env = described_class.new

      env['foo'] = 'bar'
      expect(env.fetch('foo')).to eq 'bar'
    end
  end

  describe '#fetch' do
    context 'for a magic variable' do
      it 'returns the value of the magic variable' do
        magic_variables = stub_magic_variables
        allow(magic_variables).to receive(:fetch).with(:_prior).
          and_return('a-branch-name')
        env = described_class.new

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
        allow(Gitsh::Registry[:repo]).to receive(:config).
          with('user.name', false).and_return('John Smith')
        env = described_class.new
        register(env: env)

        expect(env.fetch(:'user.name')).to eq 'John Smith'
        expect(env.fetch('user.name')).to eq 'John Smith'
      end
    end

    context 'for an unknown variable with a default block given' do
      it 'yields to the block' do
        repo = Gitsh::GitRepository.new
        env = described_class.new
        register(env: env, repo: repo)

        expect(env.fetch(:unknown) { 'default' }).to eq 'default'
      end
    end

    context 'for an unknown variable with no default block given' do
      it 'raises an error' do
        allow(Gitsh::Registry[:repo]).to receive(:config).and_raise(KeyError)
        env = described_class.new

        expect { env.fetch(:unknown) }.
          to raise_exception(Gitsh::UnsetVariableError, /unknown/)
      end
    end
  end

  describe '#available_variables' do
    it 'returns the names of all available variables' do
      register_repo(available_config_variables: [:'user.name'])
      magic_variables = stub_magic_variables(
        available_variables: [:_prior],
      )
      env = described_class.new
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
      allow(Gitsh::Registry[:repo]).to receive(:config).and_raise(KeyError)
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
        repo = Gitsh::GitRepository.new
        env = described_class.new
        register(repo: repo, env: env)

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

  describe '#config_directory' do
    it 'defaults to "/usr/local/etc/gitsh"' do
      env = described_class.new

      expect(env.config_directory).to eq '/usr/local/etc/gitsh'
    end

    it 'can be overridden with an initializer argument' do
      env = described_class.new(config_directory: '/custom/prefix/etc/gitsh')

      expect(env.config_directory).to eq '/custom/prefix/etc/gitsh'
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

  describe '#local_aliases' do
    it 'returns names of aliases defined in the gitsh session' do
      env = described_class.new
      env['aliasish'] = 'not relevant'
      env['alias.baz'] = '!echo baz'

      expect(env.local_aliases).to eq ['baz']
    end
  end

  def register(entries)
    entries.each do |key, object|
      Gitsh::Registry[key] = object
    end
  end

  def stub_magic_variables(attrs = {})
    magic_variables = instance_double(Gitsh::MagicVariables, attrs)
    allow(Gitsh::MagicVariables).to receive(:new).and_return(magic_variables)
    magic_variables
  end
end
