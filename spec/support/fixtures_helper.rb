# frozen_string_literal: true

module FixturesHelper
  def fixture_path(*file_name)
    File.expand_path File.join(__dir__, "..", "fixtures", *file_name)
  end
end

RSpec.configure do |config|
  config.include FixturesHelper
end
