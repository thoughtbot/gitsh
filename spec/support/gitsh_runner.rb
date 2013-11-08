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

  def last_prompt
    readline.last_prompt
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
end
