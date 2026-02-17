# frozen_string_literal: true

require "capybara/rspec"
require "capybara/cuprite"

Capybara.default_max_wait_time = 5
Capybara.server = :puma, {Silent: true}
Capybara.server_host = "127.0.0.1"
