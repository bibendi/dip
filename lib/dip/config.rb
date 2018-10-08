# frozen_string_literal: true

require "yaml"
require "erb"

module Dip
  class Config
    DEFAULT_PATH = "dip.yml"

    def initialize
      @path = ENV["DIP_FILE"] || File.join(Dir.pwd, DEFAULT_PATH)
    end

    def exist?
      File.exist?(@path)
    end

    [:environment, :compose, :interaction, :provision].each do |key|
      define_method(key) do
        config[key]
      end
    end

    def to_h
      config
    end

    private

    def config
      @config ||= load
    end

    def load
      raise ArgumentError, "Dip config not found at path '#{@path}'" unless exist?

      @config = YAML.safe_load(
        ERB.new(File.read(@path)).result,
        [], [], true,
        symbolize_names: true
      )
    end
  end
end
