require 'thread'

class FakeReadline
  def initialize
    @queue = Queue.new
  end

  def readline(prompt, add_to_history)
    @queue.pop
  end

  def type(string)
    @queue << string
  end
end
