# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

# Register Cuprite as the driver
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1440, 900],
    browser_options: {
      'no-sandbox': nil,
      'disable-gpu': nil,
      'disable-dev-shm-usage': nil
    },
    process_timeout: 30,
    timeout: 10,
    inspector: ENV['INSPECTOR'].present?,
    headless: ENV['HEADLESS'] != 'false'
  )
end

# Set Cuprite as default driver for system tests
Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite

# Configure Capybara
Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.server = :puma, { Silent: true }
  config.save_path = Rails.root.join('tmp/capybara')
end

# Save screenshots on failure
RSpec.configure do |config|
  config.after(:each, type: :system) do |example|
    if example.exception
      filename = "#{example.full_description.gsub(/\s+/, '_').gsub(/[^\w]/, '')}_#{Time.now.to_i}"
      page.save_screenshot("#{Capybara.save_path}/#{filename}.png")
    end
  end
end
