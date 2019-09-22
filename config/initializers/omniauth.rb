# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FB_APP_ID'], ENV['FB_APP_SECRET'], scope: 'email', info_fields: 'email,name'
end
