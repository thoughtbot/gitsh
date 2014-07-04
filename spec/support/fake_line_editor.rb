require 'thread'
require 'gitsh/module_delegator'

class FakeLineEditor < ModuleDelegator
  def initialize
    @prompt_queue = Queue.new
    @input_read, @input_write = IO.pipe
    super(Readline)
  end

  def readline(prompt, add_to_history)
    module_delegator_target.input = input_read
    module_delegator_target.output = output_file
    prompt_queue.clear
    prompt_queue << prompt
    module_delegator_target.readline(prompt, add_to_history)
  end

  def type(string)
    input_write << "#{string}\n"
  end

  def send_eof
    input_write.close
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
      File.open(Tempfile.new('line_editor_out').path, 'w')
    end
  end
end
