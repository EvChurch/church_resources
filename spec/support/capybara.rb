# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

CHROME_AVAILABLE = ENV.fetch('BROWSER_PATH', nil) || %w[
  google-chrome chromium chromium-browser
].any? { |name| system("which #{name}", out: File::NULL, err: File::NULL) }

Capybara.register_driver(:cuprite) do |app|
  options = {
    window_size: [1400, 1400],
    js_errors: true,
    timeout: 30
  }
  if ENV['CI']
    options[:process_timeout] = 30
    options[:browser_options] = { 'no-sandbox': nil, 'disable-dev-shm-usage': nil }
  end
  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite

RSpec.configure do |config|
  config.before(:each, js: true) do
    skip 'Chrome/Chromium not found — install it or set BROWSER_PATH' unless CHROME_AVAILABLE
  end
end
