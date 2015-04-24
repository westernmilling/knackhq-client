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

#GET all objects in api.
api.objects
#Output:
[{:name=>"Foo", :key=>"object_1"}
{:name=>"Bar", :key=>"object_2"}]

#GET object_1 fields
api.fields('object_1')
#Output:
[{:label=>"Number", :key=>"field_1", :type=>"float", :required=>false, :field_type=>"number"},
{:label=>"Last Date", :key=>"field_12", :type=>"datetime", :required=>false, :field_type=>"date_time"}]

#GET object_1 records
api.records('object_1')
#Output:
{:total_pages=>2, :current_page=>1, :total_records=>28, :records=>[{:id=>"23456", :account_status=>"active", :approval_status=>"approved", :profile_keys=>"Bar", :profile_keys_raw=>[{:id=>"12345", :identifier=>"Bar"}], :field_32=>"First Name", :field_32_raw=>{:last=>"Last", :first=>"First"}, :field_33=>"<a href=\"mailto:flast@example.com\">flast@example.com</a>", :field_33_raw=>{:email=>"flast@example.com"}, :field_34=>"*********", :field_34_raw=>"**********", :field_188=>"<span class=\"23456\">Bar</span>", :field_188_raw=>[{:id=>"23456", :identifier=>"Bar"}]}]}

#GET object_1 record
#Knackhq record ID is 12345
api.update_record('object_1', '12345')

#GET object_1
api.object('object_1')
#Output
{:id=>"34567", :default=>"", :key=>"field_1", :name=>"Foo", :rules=>[], :conditional=>false, :user=>false, :unique=>true, :required=>true, :immutable=>false, :type=>"short_text"}

#PUT object_1 record
#Knackhq ID is 12345
api.update_record('object_1', '12345', { field_name: value }.to_json)
#Output:
true/false
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knackhq-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
