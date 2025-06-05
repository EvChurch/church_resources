# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1400, 1400], js_errors: true)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
