# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TerminalDnd
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w[assets tasks])

    # Time zone
    config.time_zone = "UTC"

    # Generators
    config.generators do |g|
      g.orm :active_record, primary_key_type: :integer
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end
  end
end
