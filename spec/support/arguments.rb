module Arguments
  def arguments(*values)
    double("ArgumentList", values: values, length: values.length)
  end
end

RSpec.configure do |config|
  config.include Arguments
end
