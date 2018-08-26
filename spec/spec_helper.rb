require "bundler/setup"

require "simplecov"
SimpleCov.start do
  minimum_coverage 97
end

require "pry-byebug"
require "dip"
require "fakefs/spec_helpers"
require_relative "support/env"
require_relative "support/config"

RSpec.configure do |config|
  config.include(FakeFS::SpecHelpers, fakefs: true)

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Dip.reset!
  end

  config.around(:each) do |example|
    with_env("DIP_FILE" => "some-test-dip.yml") { example.run }
  end
end
