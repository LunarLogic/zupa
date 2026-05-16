require "vcr"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    # reindex models
    # and disable callbacks
    # Searchkick.disable_callbacks
  end

  config.before(:each, :requires_auth) do
    headers = {"Authorization" => "Bearer token"}
    allow_any_instance_of(ActionDispatch::Request).to receive(:headers).and_return(headers)
    allow_any_instance_of(Auth::Authorize).to receive(:call).and_return(true)
  end

  config.around(:each, :vcr) do |example|
    vcr_tag = example.metadata[:vcr]
    options = vcr_tag.is_a?(Hash) ? vcr_tag : {}

    VCR.use_cassette(example.description, options) { example.call }
  end
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/support/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
  config.filter_sensitive_data("<AUTHORIZATION>") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end
  config.filter_sensitive_data("<ACCESS_TOKEN>") do |interaction|
    match = interaction.response.body.match(/"access_token":"([^"]+)"/)
    match[1] if match
  end
  config.filter_sensitive_data("<OAUTH_ASSERTION>") do |interaction|
    match = interaction.response.body.match(/jwt-bearer&assertion=([^&"]+)/)
    match[1] if match
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
