class SignallingReadline
  def initialize(signal)
    @signal = signal
  end

  def readline(*args, &block)
    Process.kill(signal, Process.pid)
    nil
  end

  def method_missing(name, *args, &block)
  end

  private

  attr_reader :signal
end
