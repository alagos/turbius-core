source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.6'

# Data
gem 'pg'
gem 'paper_trail', '~> 3.0.6' # Track changes to your models' data. Good for auditing or versioning.

# Assets
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'haml-rails'
gem 'simple_form'

# Javascript
# gem 'jquery-rails'
# gem 'turbolinks'
# gem 'jquery-turbolinks'
# gem 'nprogress-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Email
# gem 'premailer-rails'
# gem 'nokogiri' # premailer-rails depends on this

# Authentication
gem 'devise'
gem 'cancancan', '~> 1.9'

# Admin
gem 'rails_admin'

# Workers
# gem 'sidekiq'
# gem 'devise-async'
# gem 'sinatra', require: false
# gem 'rspec-sidekiq', group: :test

# Utils
# gem 'addressable' # a replacement for the URI implementation that is part of Ruby's standard library
gem 'figaro'
gem 'settingslogic'

gem 'nokogiri'
gem 'rest-client'

group :development do
  # Docs
  # gem 'sdoc', '~> 0.4.0', require: false    # bundle exec rake doc:rails
  gem 'annotate'

  # Errors
  gem 'better_errors'
  gem 'binding_of_caller'     # extra features for better_errors
  # gem 'meta_request'          # for rails_panel chrome extension

  # Deployment
  # gem 'capistrano-rails'

  # Guard
  gem 'guard-rspec'
  # gem 'guard-livereload'
  # gem 'rack-livereload'
end

group :development, :test do
  # Use spring or zeus
  gem 'spring'                  # keep application running in the background
  gem 'spring-commands-rspec'
  # gem 'zeus'                  # required in gemfile for guard

  # Debugging
  # gem 'pry'                   # better than irb
  # gem 'byebug'                # ruby 2.0 debugger with built-in pry
  gem 'pry-rails'               # adds rails specific commands to pry
  gem 'pry-byebug'              # add debugging commands to pry
  gem 'pry-stack_explorer'      # navigate call stack
  # gem 'pry-rescue'            # start pry session on uncaught exception
  # gem 'pry-doc'               # browse docs from console
  # gem 'pry-git'               # add git support to console
  # gem 'pry-remote'            # connect remotely to pry console
  # gem 'coolline'              # sytax highlighting as you type
  # gem 'coderay'               # use with coolline
  gem 'awesome_print'           # pretty pring debugging output

  # Testing
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'capybara-webkit'
  # gem 'poltergeist'           # alternative to capybara-webkit
  # gem 'capybara-firebug'
  # gem 'launchy'               # save_and_open_page support for rspec
  # gem 'zeus-parallel_tests'   # speed up lengthy tests

  # Logging
  gem 'quiet_assets'

  gem 'rb-inotify', require: false # monitor file changes without hammering the disk
end


group :test do
  gem 'minitest'                # include minitest to prevent require 'minitest/autorun' warnings

  # Helpers
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  # gem 'timecop'               # Mock Time

  # Coverage
  gem 'simplecov', require: false

end

group :production do
  # gem 'dalli'                   # memcached
  # gem 'memcachier'              # heroku add-on for auto config of dalli
  gem 'unicorn'
  gem 'rails_12factor'          # https://devcenter.heroku.com/articles/rails4
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'

