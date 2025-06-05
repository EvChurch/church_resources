# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 options: Selenium::WebDriver::Chrome::Options.new.tap do |opts|
                                   opts.add_argument('--headless')
                                   opts.add_argument('--disable-gpu')
                                   opts.add_argument('--window-size=1400,1400')
                                 end)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :headless_chrome
