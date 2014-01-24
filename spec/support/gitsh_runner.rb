require 'thread'
require 'tempfile'
require 'gitsh/cli'
require 'gitsh/environment'
require File.expand_path('../file_system', __FILE__)

class GitshRunner
  include FileSystemHelper

  def self.interactive(options={}, &block)
    new.run_interactive(options, &block)
  end

  def initialize
    @output_stream = Tempfile.new('stdout')
    @error_stream = Tempfile.new('stderr')
    @readline = FakeReadline.new
  end

  def run_interactive(options={})
    runner = nil
    in_a_temporary_directory do
      setup_env(options.fetch(:env, {}))

      Thread.abort_on_exception = true
      runner = Thread.new do
        env = Gitsh::Environment.new(
          output_stream: output_stream,
          error_stream: error_stream
        )
        cli = Gitsh::CLI.new(
          args: options.fetch(:args, []),
          env: env,
          readline: readline
        )
        begin
          cli.run
        rescue SystemExit
        end
      end

      wait_for_prompt

      yield(self)

      readline.type(':exit')
      runner.join
    end
  rescue RSpec::Expectations::ExpectationNotMetError => e
    runner.kill
    runner.join
    raise
  end

  def type(string)
    @position_before_command = output_stream.pos
    readline.type(string)
    wait_for_prompt
  end

  def prompt
    @prompt
  end

  def output
    output_stream.seek(@position_before_command)
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

  def wait_for_prompt
    @prompt = readline.prompt
  end

  def setup_env(env)
    {'TERM' => 'vt220'}.merge(env).each do |key, value|
      ENV[key] = value
    end
  end
end

RSpec::Matchers.define :prompt_with do |expected|
  match do |runner|
    @actual = runner.prompt
    expect(@actual).to eq expected
  end

  failure_message_for_should do |runner|
    "Expected #{expected.inspect}, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output do |expected|
  match do |runner|
    @actual = runner.output
    expect(@actual).to match_regex expected
  end

  failure_message_for_should do |runner|
    "Expected #{expected.inspect}, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output_no_errors do
  match do |runner|
    @actual = runner.error
    expect(@actual).to be_empty
  end

  failure_message_for_should do |runner|
    "Expected no errors, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output_error do |expected|
  match do |runner|
    @actual = runner.error
    expect(@actual).to match_regex expected
  end

  failure_message_for_should do |runner|
    "Expected error #{expected.inspect}, got #{@actual.inspect}"
  end
end
