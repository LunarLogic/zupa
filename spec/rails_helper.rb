# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
end
FactoryBot.rewind_sequences

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

ActiveJob::Base.queue_adapter = :test

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers
  config.include ActiveSupport::Testing::TimeHelpers
end
