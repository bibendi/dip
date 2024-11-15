# frozen_string_literal: true

require "yaml"
require "erb"
require "pathname"
require "json-schema"

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
      infra: {},
      interaction: {},
      provision: []
    }.freeze

    TOP_LEVEL_KEYS = %i[environment compose kubectl infra interaction provision].freeze

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

      def modules_dir
        file_path.dirname / ".dip"
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

    def module_file(filename)
      finder.modules_dir / "#{filename}.yml"
    end

    def exist?
      finder.exist?
    end

    def to_h
      config
    end

    TOP_LEVEL_KEYS.each do |key|
      define_method(key) do
        config[key] || (raise config_missing_error(key))
      end
    end

    def validate
      raise Dip::Error, "Config file path is not set" if file_path.nil?
      raise Dip::Error, "Config file not found: #{file_path}" unless File.exist?(file_path)

      schema_path = File.join(File.dirname(__FILE__), "../../schema.json")
      raise Dip::Error, "Schema file not found: #{schema_path}" unless File.exist?(schema_path)

      data = YAML.load_file(file_path)
      schema = JSON.parse(File.read(schema_path))
      JSON::Validator.validate!(schema, data)
    rescue Psych::SyntaxError => e
      raise Dip::Error, "Invalid YAML syntax in config file: #{e.message}"
    rescue JSON::Schema::ValidationError => e
      data_display = data ? data.to_yaml.gsub("\n", "\n  ") : "nil"
      error_message = "Schema validation failed: #{e.message}\nInput data:\n  #{data_display}"
      raise Dip::Error, error_message
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

      base_config = {}

      if (modules = config[:modules])
        raise Dip::Error, "Modules should be specified as array" unless modules.is_a?(Array)

        modules.each do |m|
          file = module_file(m)
          raise Dip::Error, "Could not find module `#{m}`" unless file.exist?

          module_config = self.class.load_yaml(file)
          raise Dip::Error, "Nested modules are not supported" if module_config[:modules]

          base_config.deep_merge!(module_config)
        end
      end

      base_config.deep_merge!(config)

      override_finder = ConfigFinder.new(work_dir, override: true)
      base_config.deep_merge!(self.class.load_yaml(override_finder.file_path)) if override_finder.exist?

      @config = CONFIG_DEFAULTS.merge(base_config)

      validate

      @config
    end

    def config_missing_error(config_key)
      msg = "config for %<key>s is not defined in %<path>s" % {key: config_key, path: finder.file_path}
      ConfigKeyMissingError.new(msg)
    end
  end
end
