require 'thread'
require 'tempfile'
require 'gitsh/cli'
require File.expand_path('../file_system', __FILE__)

class GitshRunner
  include FileSystemHelper

  def self.interactive(env={}, &block)
    new.run_interactive(env, &block)
  end

  def initialize
    @output_stream = Tempfile.new('stdout')
    @error_stream = Tempfile.new('stderr')
    @readline = FakeReadline.new
  end

  def run_interactive(env={})
    in_a_temporary_directory do
      setup_env(env)

      Thread.abort_on_exception = true
      runner = Thread.new do
        Gitsh::CLI.new(
          args: [],
          output: output_stream,
          error: error_stream,
          readline: readline
        ).run
      end

      wait_for_prompt

      yield(self)

      readline.type('exit')
      runner.join
    end
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
