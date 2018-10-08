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

    %i[environment compose interaction provision].each do |key|
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
        [], [], true
      )

      deep_symbolyze_keys!(@config)

      @config
    end

    # rubocop:disable Metrics/MethodLength
    def deep_symbolyze_keys!(object)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          key = key.to_sym if key.is_a?(String)
          object[key] = deep_symbolyze_keys!(value)
        end

        object
      when Array
        object.map! { |e| deep_symbolyze_keys!(e) }
      else
        object
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
