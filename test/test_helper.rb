# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "minitest/unit"
require "minitest/autorun"
require 'database_cleaner/active_record'
require 'ffaker'
require 'factory_bot'
require 'webmock/minitest'

Rails.backtrace_cleaner.remove_silencers!

#include factories
Dir["#{File.dirname(__FILE__)}/dummy/test/factories/*.rb"].each { |f| require f }
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
# if ActiveSupport::TestCase.method_defined?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
#   ActiveSupport::TestCase.fixtures :all
# end

class Minitest::Spec
  include FactoryBot::Syntax::Methods

  before :each do
    stub_request(:any, "https://api.fastly.com/login").
      to_return(
        :status   => 200,
        :body     => "{}"
    )
    stub_request(:post, /https:\/\/api.fastly.com\/service\/.*\/purge\/.*/)
    .to_return(
      body: "{\"status\":\"ok\"}"
    )

    WebMock.disable_net_connect!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

end

class ActionController::TestCase
  include FactoryBot::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  include WebMock::API
  include FactoryBot::Syntax::Methods

  def setup
    stub_request(:any, /.*/).
    to_return(
        :status   => 200,
        :body     => "{}"
    )

  end

end
