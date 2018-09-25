# frozen_string_literal: true

require "bundler/setup"

ENV["DIP_ENV"] = "test"

require "simplecov"
SimpleCov.start do
  # minimum_coverage 97
end

require "pry-byebug"
require "dip"

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.define_derived_metadata(file_path: %r{/spec/lib/commands}) do |metadata|
    metadata[:runner] = true
  end

  config.before(:each) do
    Dip.reset!
  end

  Kernel.srand config.seed
end
