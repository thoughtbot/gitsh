require 'gitsh/arguments/string_value'

module ArgumentValues
  def string_value(string)
    Gitsh::Arguments::StringValue.new(string)
  end
end

RSpec.configure do |config|
  config.include ArgumentValues
end
