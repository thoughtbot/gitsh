require 'thread'

class FakeReadline
  def initialize
    @input_queue = Queue.new
    @prompt_queue = Queue.new
  end

  def readline(prompt, add_to_history)
    @prompt_queue << prompt
    @input_queue.pop
  end

  def type(string)
    @input_queue << string
  end

  def prompt
    @prompt_queue.pop
  end
end
