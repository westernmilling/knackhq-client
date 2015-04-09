# Knackhq::Client
[![Gem Version](https://badge.fury.io/rb/knackhq-client.svg)](http://badge.fury.io/rb/knackhq-client) [![Build Status](https://travis-ci.org/westernmilling/knackhq-client.svg?branch=master)](https://travis-ci.org/westernmilling/knackhq-client) [![Dependency Status](https://gemnasium.com/westernmilling/knackhq-client.svg)](https://gemnasium.com/westernmilling/knackhq-client) [![Code Climate](https://codeclimate.com/github/westernmilling/knackhq-client/badges/gpa.svg)](https://codeclimate.com/github/westernmilling/knackhq-client)
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knackhq-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knackhq-client

## Usage

```Ruby
api = Knackhq::Client.new('knack-api-url',
                    x_knack_application_id,
                    x_knack_rest_api_key)
#GETs the request.
api.request.get

#GET all objects in api.
api.objects

#GET object_1 fields
api.fields('object_1')

#GET object_1 records
api.records('object_1')

#GET object_1 records by page
api.records_by_page('object_1')

#Get object_1 info on records
api.records_info('object_1')

#GET object_1
api.object('object_1')

#PUT object_1 record
#Knackhq ID is 12345
api.update_record('object_1', '12345', { field_name: value }.to_json)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knackhq-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
