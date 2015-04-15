$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'knackhq/client'
require 'vcr'
require 'rspec/its'
require 'webmock'
require 'support/vcr'
require 'codeclimate-test-reporter'
require 'simplecov'
SimpleCov.start

CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
