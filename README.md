# Knackhq::Client

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
api.all_objects
#GET object_1
api.object('object_1')

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knackhq-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
