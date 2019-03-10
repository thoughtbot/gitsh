require 'thread'
require 'tempfile'
require 'tmpdir'
require 'gitsh/cli'
require 'gitsh/environment'
require 'gitsh/line_editor_history_filter'
require 'rspec/mocks/test_double'
require File.expand_path('../file_system', __FILE__)

class GitshRunner
  include FileSystemHelper

  UP_ARROW = "\033[A"

  def self.interactive(options={}, &block)
    new(options).run_interactive(&block)
  end

  def initialize(options)
    @input_stream = RSpec::Mocks::Double.new('STDIN', tty?: true, to_i: 0)
    @output_stream = Tempfile.new('stdout')
    @error_stream = Tempfile.new('stderr')
    @line_editor = Gitsh::LineEditorHistoryFilter.new(FakeLineEditor.new)
    @position_before_command = 0
    @error_position_before_command = 0
    @options = options
  end

  def run_interactive
    @runner = nil
    with_a_temporary_home_directory do
      in_a_temporary_directory do
        setup_unix_env
        @runner = start_runner_thread
        wait_for_prompt

        yield(self)

        line_editor.type(':exit')
        @runner.join
        @runner = nil
      end
    end
  rescue RSpec::Expectations::ExpectationNotMetError
    @runner.kill
    @runner.join
    @runner = nil
    raise
  end

  def type(string)
    type_without_waiting(string)
    wait_for_prompt
  end

  def type_without_waiting(string)
    @error_position_before_command = error_stream.pos
    @position_before_command = output_stream.pos
    line_editor.type(string)
  end

  def wait_for_output
    while output_stream.pos == @position_before_command
      sleep 0.001
    end
  end

  def send_sigint
    @runner.raise(Interrupt)
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
    error_stream.seek(@error_position_before_command)
    error_stream.read
  end

  def inspect
    'gitsh'
  end

  private

  attr_reader :input_stream, :output_stream, :error_stream, :line_editor, :options

  def start_runner_thread
    Thread.abort_on_exception = true
    Thread.new do
      begin
        cli.run
      rescue SystemExit
      end
    end
  end

  def cli
    Gitsh::CLI.new(
      args: options.fetch(:args, []),
      env: env,
      interactive_input_strategy: interactive_input_strategy
    )
  end

  def interactive_input_strategy
    Gitsh::InputStrategies::Interactive.new(
      line_editor: line_editor,
      env: env
    )
  end

  def env
    @env ||= Gitsh::Environment.new(
      input_stream: input_stream,
      output_stream: output_stream,
      error_stream: error_stream,
      config_directory: File.expand_path('../../../etc', __FILE__),
    ).tap do |env|
      env['gitsh.historyFile'] = File.join(Dir.tmpdir, 'gitsh_test_history')
      options.fetch(:settings, {}).each do |key, value|
        env[key] = value
      end
    end
  end

  def wait_for_prompt
    @prompt = line_editor.prompt
  end

  def setup_unix_env
    env = options.fetch(:env, {})
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

  failure_message do |runner|
    "Expected #{expected.inspect}, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output_nothing do
  match do |runner|
    @actual = runner.output
    expect(@actual).to be_empty
  end

  failure_message do |runner|
    "Expected no output, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output do |expected|
  match do |runner|
    @actual = runner.output
    expect(@actual).to match_regex expected
  end

  failure_message do |runner|
    "Expected #{expected.inspect}, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output_no_errors do
  match do |runner|
    @actual = runner.error
    expect(@actual).to be_empty
  end

  failure_message do |runner|
    "Expected no errors, got #{@actual.inspect}"
  end
end

RSpec::Matchers.define :output_error do |expected|
  match do |runner|
    @actual = runner.error
    expect(@actual).to match_regex expected
  end

  failure_message do |runner|
    "Expected error #{expected.inspect}, got #{@actual.inspect}"
  end
end
