# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.8'

gem 'activeadmin', '~> 3.3.0'
gem 'active_admin_datetimepicker'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bootstrap4-kaminari-views'
gem 'concurrent-ruby', '1.3.4' # Fix for Rails 7.0 Logger compatibility
gem 'devise'
gem 'draper'
gem 'font-awesome-sass', '~> 6.0'
gem 'formtastic', '>= 4.0'
gem 'friendly_id', '~> 5.2.4'
gem 'graphql'
gem 'high_voltage', '~> 3.1'
gem 'httparty'
gem 'image_processing', '~> 1.2'
gem 'koala'
gem 'mechanize'
gem 'meta-tags', '~> 2.22'
gem 'mini_magick'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rack-cors'
gem 'rails', '~> 7.0.0'
gem 'redis'
gem 'rolify'
gem 'rollbar'
gem 'sass-rails', '~> 5'
gem 'shakapacker', '~> 8.0'
gem 'simple_form'
gem 'turbolinks', '~> 5'
gem 'validate_url'

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'letter_opener'
  gem 'listen', '~> 3.8'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-graphql'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'cuprite'
  gem 'database_cleaner-active_record'
end

gem 'graphiql-rails', group: :development
