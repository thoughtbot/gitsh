require 'thread'

class FakeReadline
  def initialize
    @prompt_queue = Queue.new
    @input_read, @input_write = IO.pipe
  end

  def method_missing(method_name, *args, &block)
    Readline.send(method_name, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    Readline.respond_to?(method_name, include_private)
  end

  def readline(prompt, add_to_history)
    Readline.input = input_read
    Readline.output = output_file
    prompt_queue.clear
    prompt_queue << prompt
    Readline.readline(prompt, add_to_history)
  end

  def type(string)
    input_write << "#{string}\n"
  end

  def prompt
    prompt_queue.pop
  end

  private

  attr_reader :prompt_queue, :input_read, :input_write

  def output_file
    if ENV['DEBUG']
      $stdout
    else
      File.open(Tempfile.new('readline_out').path)
    end
  end
end
