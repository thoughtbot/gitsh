module FixturesHelper
  def fake_git_path
    File.expand_path('../../../spec/fixtures/fake_git', __FILE__)
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
