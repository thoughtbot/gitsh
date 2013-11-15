require 'thread'
require 'tempfile'
require 'gitsh/cli'

class GitshRunner
  def self.interactive(env={}, &block)
    new.run_interactive(env, &block)
  end

  def initialize
    @output_stream = Tempfile.new('stdout')
    @error_stream = Tempfile.new('stderr')
    @readline = FakeReadline.new
  end

  def run_interactive(env={})
    setup_env(env)

    Thread.abort_on_exception = true
    runner = Thread.new do
      in_a_test_repository do
        Gitsh::CLI.new(output_stream, error_stream, readline).run
      end
    end

    yield(self)

    readline.type('exit')
    runner.join
  end

  def type(string)
    wait_for_output { readline.type(string) }
  end

  def prompt
    readline.prompt
  end

  def output
    output_stream.rewind
    output_stream.read
  end

  def error
    error_stream.rewind
    error_stream.read
  end

  def inspect
    'gitsh'
  end

  private

  attr_reader :output_stream, :error_stream, :readline

  def in_a_test_repository(&block)
    Dir.mktmpdir do |path|
      Dir.chdir(path, &block)
    end
  end

  def wait_for_output
    output_offset, error_offset = output_stream.pos, error_stream.pos
    yield
    while output_stream.pos == output_offset && error_stream.pos == error_offset
      sleep 0.01
    end
  end

  def setup_env(env)
    {'TERM' => 'vt220'}.merge(env).each do |key, value|
      ENV[key] = value
    end
  end
end

RSpec::Matchers.define :prompt_with do |expected|
  match do |runner|
    expect(runner.prompt).to eq expected
  end
end

RSpec::Matchers.define :output do |expected|
  match do |runner|
    expect(runner.output).to match_regex expected
  end
end

RSpec::Matchers.define :output_no_errors do
  match do |runner|
    expect(runner.error).to be_empty
  end
end
