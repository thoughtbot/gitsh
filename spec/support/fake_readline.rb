require 'thread'

class FakeReadline
  def initialize
    @queue = Queue.new
  end

  def readline(prompt, add_to_history)
    @prompt = prompt
    @queue.pop
  end

  def type(string)
    @queue << string
  end

  def last_prompt
    @prompt
  end
end
