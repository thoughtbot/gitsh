require 'bourne'
require 'parslet/rig/rspec'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |path|
  require path
end

RSpec.configure do |config|
  config.mock_with :mocha
end
