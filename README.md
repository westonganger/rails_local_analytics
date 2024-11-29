# Rails Local Analytics

<a href="https://badge.fury.io/rb/rails_local_analytics" target="_blank"><img height="21" style='border:0px;height:21px;' border='0' src="https://badge.fury.io/rb/rails_local_analytics.svg" alt="Gem Version"></a>
<a href='https://github.com/westonganger/rails_local_analytics/actions' target='_blank'><img src="https://github.com/westonganger/rails_local_analytics/actions/workflows/test.yml/badge.svg?branch=master" style="max-width:100%;" height='21' style='border:0px;height:21px;' border='0' alt="CI Status"></a>
<a href='https://rubygems.org/gems/rails_local_analytics' target='_blank'><img height='21' style='border:0px;height:21px;' src='https://img.shields.io/gem/dt/rails_local_analytics?color=brightgreen&label=Rubygems%20Downloads' border='0' alt='RubyGems Downloads' /></a>

Simple, performant, local analytics for Rails. Solves 95% of your needs until your ready to start taking analytics more seriously using another tool.

Out of the box the following request details are tracked:

- day
- total (count per day)
- url_hostname (site)
- url_path (page)
- referrer_hostname
- referrer_path
- platform (ios, android, linux, osx, windows, etc)
- [browser_engine](https://en.wikipedia.org/wiki/Comparison_of_browser_engines) (blink, gecko, webkit, or nil)

It is fully customizable to store more details if desired.

## Screenshots

![Screenshot 1](/screenshot_1.png)

![Screenshot 2](/screenshot_2.png)

![Screenshot 3](/screenshot_3.png)

## Installation

```ruby
# Gemfile
gem "rails_local_analytics"
```

Add the following migration to your app:

```
bundle exec rails g migration CreateAnalyticsTables
```

```ruby
# db/migrations/..._create_analytics_tables.rb

class CreateAnalyticsTables < ActiveRecord::Migration[6.0]
  def up
    create_table :tracked_requests_by_day_page do |t|
      t.date :day, null: false
      t.bigint :total, null: false, default: 1
      t.string :url_hostname, null: false
      t.string :url_path, null: false
      t.string :referrer_hostname
      t.string :referrer_path
    end
    add_index :tracked_requests_by_day_page, :date

    create_table :tracked_requests_by_day_site do |t|
      t.date :day, null: false
      t.bigint :total, null: false, default: 1
      t.string :url_hostname, null: false
      t.string :platform
      t.string :browser_engine
    end
    add_index :tracked_requests_by_day_site, :date
  end

  def down
    drop_table :tracked_requests_by_day_page
    drop_table :tracked_requests_by_day_site
  end
end
```

Add the route for the analytics dashboard at the desired endpoint:

```ruby
# config/routes.rb
mount RailsLocalAnalytics::Engine, at: "/admin/analytics"
```

Its generally recomended to use a background job (especially since we now have [`solid_queue`](https://github.com/rails/solid_queue/)). If you would like to disable background jobs you can use the following config:

```ruby
# config/initializers/rails_local_analytics.rb
RailsLocalAnalytics.config.background_jobs = false # defaults to true
```

The next step is to collect traffic.

## Recording requests

There are two types of analytics that we mainly target:

- Site level analytics
  * Stored in the table `tracked_requests_by_day_site`
- Page level analytics
  * Stored in the table `tracked_requests_by_day_page`

Your controllers have to manually call `RailsLocalAnalytics.record_request`. For example:

```ruby
class ApplicationController < ActionController::Base
  after_action :record_page_view

  private

  def record_page_view
    return if !request.format.html? && !request.format.json?

    ### We accept manual overrides of any of the database fields
    ### For example if you wanted to track bots:
    site_based_attrs = {}
    if some_custom_bot_detection_method
      site_based_attrs[:platform] = "bot"
    end

    RailsLocalAnalytics.record_request(
      request: request,
      custom_attributes: { # optional
        TrackedRequestsByDaySite.name => site_based_attrs,
        #TrackedRequestsByDayPage.name => {},
      },
    )
  end
end
```

If you need to add more data to your events you can simply add more columns to the analytics tables and then populate these columns using the `:custom_attributes` argument.

Some examples of additional things you may want to track:

- Bot detection
  * Bot detection is difficult. As such we dont try to include it by default. Recommended gem for detection is [`crawler_detect`](https://github.com/loadkpi/crawler_detect)
  * One option is to consider not tracking bots at all in your analytics, just a thought
  * You may not need to store this in a new column, one example pattern could be to store this data in the existing `platform` database field
- Country detection
  * Country detection is difficult. As such we dont try to include it by default.
- Users or organizations
  * You may want to track your users or another model which is a core tenant to your particular application


## Performance Optimization Techniques

There are a few techniques that you can use to tailor the database for your particular needs. Heres a few examples:

- If you drop any database columns from the analytics tables this will not cause any issues. It will continue to function as normal.
- `url_hostname` column
  * If you wont ever have multi-site needs then you can consider removing this column
  * If storage space is an issue you may consider switching to an enum column as the number of permutations is probably something that can be anticipated.
- `referrer_host` and `referrer_path` columns
  *  Consider just storing "local" or nil instead if the request originated from your website
- `platform` and `browser_engine` columns
  * Consider dropping either of these if you do not need this information

## Usage where a request object is not available

If you are not in a controller or do not have access to the request object then you may pass in a hash representation. For example:

```ruby
RailsLocalAnalytics.record_request(
  request: {
    host: "http://example.com",
    path: "/some/path",
    referrer: "http://example.com/some/other/path",
    user_agent: "some-user-agent",
    http_accept_language: "some-http-accept-language",
  },
  # ...
)
```

## Deleting old data

By default all data is retained indefinately. If you would like to have automated deletion of the data, you might use the following example technique:

```ruby
class ApplicationController
  after_action :record_page_view

  private

  def record_page_view
    # perform other logic and call RailsLocalAnalytics.record_request

    TrackedRequestsByDayPage.where("date < ?", 3.months.ago).delete_all
    TrackedRequestsByDaySite.where("date < ?", 3.months.ago).delete_all
  end
end
```

## Development

Run server using: `bin/dev` or `cd test/dummy/; rails s`

## Testing

```
bundle exec rspec
```

We can locally test different versions of Rails using `ENV['RAILS_VERSION']`

```
export RAILS_VERSION=7.0
bundle install
bundle exec rspec
```

## Credits

Created & Maintained by [Weston Ganger](https://westonganger.com) - [@westonganger](https://github.com/westonganger)

Imitated some parts of [`active_analytics`](https://github.com/BaseSecrete/active_analytics). Thanks to them for the aggregate database schema idea.
