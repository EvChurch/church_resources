# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

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
