# Iapd

To build the sqlite3 database:

``` shell
rake download
rake csvs
rake database
rake update_owners_table
rake json
rake relationships
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iapd'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iapd

## Usage



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


### about the data

- [information](https://www.sec.gov/help/foiadocsinvafoiahtm.html)

- [form adv](https://www.sec.gov/about/forms/formadv-part1a.pdf)

- [csv files](https://www.sec.gov/foia/docs/form-adv-archive-data.htm)
