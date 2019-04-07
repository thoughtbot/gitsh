require 'gitsh/arguments/string_value'
require 'gitsh/arguments/pattern_value'

module ArgumentValues
  def string_value(string)
    Gitsh::Arguments::StringValue.new(string)
  end

  def pattern_value(pattern)
    Gitsh::Arguments::PatternValue.new(pattern)
  end
end

RSpec.configure do |config|
  config.include ArgumentValues
end
