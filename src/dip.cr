require "cli"
require "./dip/version"
require "./dip/cli"
require "./dip/config"
require "./dip/environment"

module Dip
  def self.config
    @@config ||= Config.from_yaml(File.read(config_path))
  end

  def self.config_path
    ENV.fetch("DIP_FILE", "./dip.yml")
  end

  def self.env
    @@env ||= Environment.new(config.environment)
  end
end

exit Dip::Cli.run(ARGV).as(Int32)
