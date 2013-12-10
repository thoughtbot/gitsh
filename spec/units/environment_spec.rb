require 'spec_helper'
require 'gitsh/environment'

describe Gitsh::Environment do
  describe '#[]=' do
    it 'sets a gitsh environment variable' do
      env = described_class.new

      expect(env[:foo]).to be_nil
      expect(env['foo']).to be_nil
      env['foo'] = 'bar'
      expect(env[:foo]).to eq 'bar'
      expect(env['foo']).to eq 'bar'
    end
  end

  describe '#output_stream' do
    it 'returns $stdout by default' do
      env = described_class.new

      expect(env.output_stream).to eq $stdout
    end

    it 'can be overridden in the constructor' do
      stream = stub
      env = described_class.new(output_stream: stream)

      expect(env.output_stream).to eq stream
    end
  end

  describe '#git_command' do
    it 'defaults to "/usr/bin/env git"' do
      env = described_class.new

      expect(env.git_command).to eq '/usr/bin/env git'
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
end
