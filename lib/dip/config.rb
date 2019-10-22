# frozen_string_literal: true

require "yaml"
require "erb"

require "dip/version"
require "dip/ext/hash"

using ActiveSupportHashHelpers

module Dip
  class Config
    DEFAULT_PATH = "dip.yml"

    class << self
      def exist?
        File.exist?(path)
      end

      def path
        ENV["DIP_FILE"] || File.join(Dir.pwd, DEFAULT_PATH)
      end

      def override_path
        path.gsub(/\.yml$/, ".override.yml")
      end

      def load_yaml(file_path = path)
        return {} unless File.exist?(file_path)

        YAML.safe_load(
          ERB.new(File.read(file_path)).result,
          [], [], true
        ).deep_symbolize_keys!
      end
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
      return @config if @config

      raise ArgumentError, "Dip config not found at path '#{self.class.path}'" unless self.class.exist?

      config = self.class.load_yaml

      unless Gem::Version.new(Dip::VERSION) >= Gem::Version.new(config.fetch(:version))
        raise VersionMismatchError, "Your dip version is `#{Dip::VERSION}`, " \
                                    "but config requires minimum version `#{config[:version]}`. " \
                                    "Please upgrade your dip!"
      end

      config.deep_merge!(self.class.load_yaml(self.class.override_path))

      @config = config
    end
  end
end
