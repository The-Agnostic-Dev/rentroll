require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Rentroll
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    # The business runs in Lagos; every "today" in the app is a Lagos today.
    config.time_zone = "Africa/Lagos"

    # Dashboard figures are memoised in-process (see DashboardSummary).
    config.cache_store = :memory_store, { size: 16 * 1024 * 1024 }

    config.generators.system_tests = nil
  end
end
