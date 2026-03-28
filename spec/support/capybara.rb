# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

CHROME_PATH = ENV.fetch('BROWSER_PATH', nil) || %w[
  google-chrome chromium chromium-browser
].find { |name| path = `which #{name} 2>/dev/null`.strip; break path unless path.empty? }

# Verify the binary actually launches (snap stubs on Ubuntu report as found but fail)
CHROME_AVAILABLE = CHROME_PATH && system(
  "#{CHROME_PATH} --headless --no-sandbox --disable-gpu --dump-dom about:blank",
  out: File::NULL, err: File::NULL
)

Capybara.register_driver(:cuprite) do |app|
  options = {
    window_size: [1400, 1400],
    js_errors: true,
    timeout: 30,
    process_timeout: 30,
    browser_options: { 'no-sandbox': nil, 'disable-dev-shm-usage': nil }
  }
  options[:browser_path] = CHROME_PATH if CHROME_PATH
  Capybara::Cuprite::Driver.new(app, **options)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite

RSpec.configure do |config|
  config.before(:each, js: true) do
    skip 'Chrome/Chromium not found — install it or set BROWSER_PATH' unless CHROME_AVAILABLE
  end
end
