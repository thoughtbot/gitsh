require 'pry'

$LOAD_PATH.unshift(File.expand_path('../../ext', __FILE__))

GITSH_CONFIG_DIRECTORY = File.expand_path('../../etc', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |path|
  require path
end

RSpec.configure do |config|
  config.order = 'random'
end

Pry.config.tap do |config|
  config.output = STDOUT
  config.input = STDIN
end
