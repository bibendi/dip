require "spec"
require "../src/dip"

ENV["CRYSTAL_CLI_ENV"] = "test"
ENV["DIP_ENV"] = "test"

Spec.before_each do
  # Remove env vars because var from ENV can broke tests,
  # for example in travis RAILS_ENV = test by default
  ENV.delete("RUBY")
  ENV.delete("RAILS_ENV")

  Dip.reset!
end

def with_dip_file(file_path = "./spec/app/dip.yml")
  ENV["DIP_FILE"] = file_path

  yield

  ENV.delete("DIP_FILE")
end
