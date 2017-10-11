require 'mumukit'

Mumukit.runner_name = 'javascript'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-mocha-worker'
  config.structured = true
  config.stateful = true
end

require_relative './version'
require_relative './metadata_hook'
require_relative './test_hook'
require_relative './expectations_hook'
require_relative './query_hook'
