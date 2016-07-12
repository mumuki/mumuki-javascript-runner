require 'mumukit'

Mumukit.runner_name = 'javascript'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-mocha-worker'
  config.structured = true
end

require_relative './metadata_hook'
require_relative './test_hook'
require_relative './query_hook'