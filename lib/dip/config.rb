# frozen_string_literal: true

require "yaml"
require "erb"

module Dip
  class Config
    DEFAULT_CONFIG = {}

    def initialize(config_path)
      load_or_default(config_path)
    end

    def merge(config)
      @config.merge!(config)
    end

    def environment
      @config.fetch(:environment, {})
    end

    def compose
      @config.fetch(:compose, {})
    end

    def interaction
      @config.fetch(:interaction, {})
    end

    def provision
      @config.fetch(:provision, [])
    end

    private

    def load_or_default(config_path)
      @config ||= if File.exist?(config_path) && !Dip.test?
                    YAML.safe_load(
                      ERB.new(File.read(config_path)).result,
                      [], [], true,
                      symbolize_names: true
                    )
                  else
                    DEFAULT_CONFIG
                  end
    end
  end
end
