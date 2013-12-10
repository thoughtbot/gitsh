module Parser
  def parser_literals(string)
    string.split('').map { |chr| { literal: chr } }
  end
end

RSpec.configure do |config|
  config.include Parser
end
