module Arguments
  def arguments(*values)
    stub("ArgumentList", values: values, length: values.length)
  end
end

RSpec.configure do |config|
  config.include Arguments
end
