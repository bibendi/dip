require "cli"
require "./dip/version.cr"
require "./dip/cli.cr"
require "./dip/config.cr"
require "./dip/environment.cr"

module Dip
  def self.config
    @@config ||= Config.from_yaml(File.read(config_path))
  end

  def self.config_path
    ENV.fetch("DIP_FILE", "./dip.yml")
  end

  def self.env
    @@env ||= Environment.new(File.exists?(config_path) ? config.environment : Hash(String, String).new)
  end
end
