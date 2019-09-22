# frozen_string_literal: true

Koala.configure do |config|
  config.app_id = ENV['FB_APP_ID']
  config.app_secret = ENV['FB_APP_SECRET']
end
