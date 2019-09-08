# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChurchResources
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins 'localhost:3000', 'aucklandev.co.nz', %r{\Ahttps:\/\/.*\.aucklandev\.co\.nz\z}
        resource(
          '*',
          headers: :any,
          methods: %i[post options]
        )
      end
    end
  end
end
