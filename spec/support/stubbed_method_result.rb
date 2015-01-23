class StubbedMethodResult
  def initialize
    @results = []
  end

  def raises(error, message = nil)
    @results << proc { raise error.new(message) }

    self
  end

  def returns(value)
    @results << proc { value }

    self
  end

  def next_result
    @results.shift.call
  end
end
