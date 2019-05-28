# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'
gem 'activeadmin'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap4-kaminari-views'
gem 'devise'
gem 'high_voltage', '~> 3.1'
gem 'image_processing', '~> 1.2'
gem 'meta-tags'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0.0.rc1'
gem 'sass-rails', '~> 5'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'
gem 'simple_form'
gem 'draper'
gem 'friendly_id', '~> 5.2.4'
gem 'httparty'
gem 'redis'
gem 'hiredis'
gem 'mechanize'

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.8'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'foreman'
  gem 'letter_opener'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
