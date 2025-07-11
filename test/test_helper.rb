ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "mocha/minitest"

# Load test support files
Dir[Rails.root.join("test", "support", "**", "*.rb")].each { |f| require f }

# Disable external HTTP requests during tests
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include test helpers
    include LlmTestHelper
    include EmailTestHelper
    include TestDataBuilder
    include Devise::Test::IntegrationHelpers

    # Add more helper methods to be used by all tests here...
  end
end
