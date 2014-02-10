class ReadlineBlankFilter < Module
  def initialize(delegate)
    @delegate = delegate
  end

  def readline(prompt, add_hist = false)
    delegate.readline(prompt, add_hist).tap do |result|
      if add_hist && result.strip.empty?
        delegate::HISTORY.pop
      end
    end
  end

  def method_missing(name, *args)
    delegate.send(name, *args)
  end

  def respond_to_missing?(name, include_all)
    delegate.respond_to?(name, include_all)
  end

  def const_missing(name)
    delegate.const_get(name)
  end

  private

  attr_reader :delegate
end
