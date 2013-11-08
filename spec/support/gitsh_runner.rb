require 'thread'
require 'tempfile'

class GitshRunner
  def self.interactive(&block)
    new.run_interactive(&block)
  end

  def initialize
    @output_stream = Tempfile.new('stdout')
    @error_stream = Tempfile.new('stderr')
    @readline = FakeReadline.new
  end

  def run_interactive
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

  def output
    output_stream.rewind
    output_stream.read
  end

  def error
    error_stream.rewind
    error_stream.read
  end

  private

  attr_reader :output_stream, :error_stream, :readline

  def in_a_test_repository(&block)
    FileUtils.rm_rf(test_repository_path)
    Dir.mkdir(test_repository_path)
    Dir.chdir(test_repository_path, &block)
    FileUtils.rm_rf(test_repository_path)
  end

  def test_repository_path
    File.expand_path('../../test_repository', __FILE__)
  end

  def wait_for_output
    original_output, original_error = String.new(output), String.new(error)
    yield
    while output == original_output && error == original_error
      sleep 0.01
    end
  end
end
