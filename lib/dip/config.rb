# frozen_string_literal: true

require "yaml"
require "erb"
require "pathname"

require "dip/version"
require "dip/ext/hash"

using ActiveSupportHashHelpers

module Dip
  class Config
    DEFAULT_PATH = "dip.yml"

    CONFIG_DEFAULTS = {
      environment: {},
      compose: {},
      kubectl: {},
      interation: {},
      provision: []
    }.freeze

    ConfigKeyMissingError = Class.new(ArgumentError)

    class ConfigFinder
      attr_reader :file_path

      def initialize(work_dir, override: false)
        @override = override

        @file_path = if ENV["DIP_FILE"]
          Pathname.new(prepared_name(ENV["DIP_FILE"]))
        else
          find(Pathname.new(work_dir))
        end
      end

      def exist?
        file_path&.exist?
      end

      private

      attr_reader :override

      def prepared_name(path)
        return path unless override

        path.gsub(/\.yml$/, ".override.yml")
      end

      def find(path)
        file = path.join(prepared_name(DEFAULT_PATH))
        return file if file.exist?
        return if path.root?

        find(path.parent)
      end
    end

    class << self
      def load_yaml(file_path = path)
        return {} unless File.exist?(file_path)

        data = if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
          YAML.safe_load(
            ERB.new(File.read(file_path)).result,
            aliases: true
          )
        else
          YAML.safe_load(
            ERB.new(File.read(file_path)).result,
            [], [], true
          )
        end

        data&.deep_symbolize_keys! || {}
      end
    end

    def initialize(work_dir = Dir.pwd)
      @work_dir = work_dir
    end

    def file_path
      finder.file_path
    end

    def exist?
      finder.exist?
    end

    def to_h
      config
    end

    %i[environment compose kubectl interaction provision].each do |key|
      define_method(key) do
        config[key] || (raise config_missing_error(key))
      end
    end

    private

    attr_reader :work_dir

    def finder
      @finder ||= ConfigFinder.new(work_dir)
    end

    def config
      return @config if @config

      raise Dip::Error, "Could not find dip.yml config" unless finder.exist?

      config = self.class.load_yaml(finder.file_path)

      unless Gem::Version.new(Dip::VERSION) >= Gem::Version.new(config.fetch(:version))
        raise VersionMismatchError, "Your dip version is `#{Dip::VERSION}`, " \
                                    "but config requires minimum version `#{config[:version]}`. " \
                                    "Please upgrade your dip!"
      end

      override_finder = ConfigFinder.new(work_dir, override: true)
      config.deep_merge!(self.class.load_yaml(override_finder.file_path)) if override_finder.exist?

      @config = CONFIG_DEFAULTS.merge(config)
    end

    def config_missing_error(config_key)
      msg = "config for %<key>s is not defined in %<path>s" % {key: config_key, path: finder.file_path}
      ConfigKeyMissingError.new(msg)
    end
  end
end
