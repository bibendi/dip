# frozen_string_literal: true

require "dip/version"
require "dip/config"
require "dip/environment"

module Dip
  Error = Class.new(StandardError)

  class << self
    def config_path
      ENV["DIP_FILE"] || "./dip.yml"
    end

    def config
      @config ||= Dip::Config.new(config_path)
    end

    def env
      @env ||= Dip::Environment.new(config.environment)
    end

    def test?
      ENV["DIP_ENV"] == "test"
    end

    def debug?
      ENV["DIP_ENV"] == "debug"
    end

    def reset!
      @config = nil
      @env = nil
    end
  end
end
