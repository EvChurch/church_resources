require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ChurchResources
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3000', 'ev.church', %r{\Ahttps:\/\/.*\.ev\.church\z}
        resource(
          '*',
          headers: :any,
          methods: %i[post options]
        )
      end
    end

    config.time_zone = 'Auckland'

  end
end
