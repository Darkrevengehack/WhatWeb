##
# This file is part of WhatWeb and may be subject to
# redistribution and commercial restrictions. Please see the WhatWeb
# web site for more information on licensing and terms of use.
# https://morningstarsecurity.com/research/whatweb
##
source 'https://rubygems.org'

# Command-line parsing (optional fallback for Ruby 3.4+)
# Note: WhatWeb now uses OptionParser (built-in) but getoptlong is kept for compatibility
gem 'getoptlong', require: false, require: false

# IP Address Ranges
gem 'ipaddr'

# IDN Domains
gem 'addressable'

# JSON logging
gem 'json'

# MongoDB logging - optional
# To use: bundle install --with mongo
group :mongo, optional: true do
  gem 'mongo'
  gem 'rchardet'
end

# Character set detection - optional
# To use: bundle install --with rchardet
# NOTE: Removed duplicate - now only defined once
group :rchardet, optional: true do
  gem 'rchardet'
end

# Development dependencies required for tests
group :test do
  gem 'rake'
  # Support both older and newer Ruby versions
  gem 'minitest', '>= 5.14.2', '< 6.0'
  gem 'rubocop', '~> 1.0'
  gem 'rdoc'
  gem 'bundler-audit'
  gem 'simplecov', require: false
end

# Needed for debugging WhatWeb
group :development do
  gem 'pry', :require => false
  gem 'rb-readline', :require => false # needed by pry on some systems
end
