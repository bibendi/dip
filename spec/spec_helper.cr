require "spec"
require "../src/dip"

def with_dip_file(file_path = "./spec/dip.yml")
  ENV["DIP_FILE"] = file_path

  yield

  ENV.delete("DIP_FILE")
end
