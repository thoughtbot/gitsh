module Scripts
  def gitsh_path
    File.expand_path('../../../bin/gitsh', __FILE__)
  end
end

RSpec.configure do |config|
  config.include Scripts
end
