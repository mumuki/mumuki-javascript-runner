require 'mumukit'

Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-mocha-worker'
  config.runner_name = 'mocha-server'
  config.structured = true
end

require_relative './metadata_hook'
require_relative './test_hook'
require_relative './query_hook'