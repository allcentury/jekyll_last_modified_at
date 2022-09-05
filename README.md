# JekyllLastModifiedAt

JekyllLastModifiedAt is an alternative to [jekyll-last-modified-at](https://github.com/gjtorikian/jekyll-last-modified-at).  The difference is how the timestamp is determined.

Take for example this jeklly post:

```
---
title: Testing Last Modified At
layout: last_modified_at
---

Here are the best cookies:

{% for cookie in site.data.cookies %}

  {{ cookie }}

{% endfor %}

```

With this gem, you can change the data in `site.data.cookies` and a new last-modified-at will be computed and available both to [jekyll-sitemap](https://github.com/jekyll/jekyll-sitemap) and as a liquid tag under `{% last_modified_at %} last modifed at: {% endlast_modified_at %}`.  Unfortunately jekyll-last-modified-at only uses git history to determine the timestmap, where this gem looks at the rendered object and computes a checksum to determine if the content has changed.

It does this by saving a file that you should include in git, `last_modified_at.json`.  You'll see it after you run `jekyll serve` or `jekyll build`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll_last_modified_at'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jekyll_last_modified_at

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jekyll_last_modified_at.
