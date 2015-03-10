require 'vcr'

real_requests = ENV['REAL_REQUESTS']

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true if real_requests
end

RSpec.configure do |config|
  config.before(:each) do
    VCR.eject_cassette
  end if real_requests
end
