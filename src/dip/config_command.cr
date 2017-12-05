require "./command"

module Dip
  class ConfigCommand < ::Dip::Command
    MIN_CONFIG_VERSION = 1
    VERSION_MISSMATCH_EXIT_CODE = 10

    def initialize(*args)
      super

      check_config_version
    end

    private def check_config_version
      return if ::Dip.config.version.to_i >= MIN_CONFIG_VERSION

      msg = "Your dip can only works with version `#{MIN_CONFIG_VERSION}` or above,"
      msg += " but current config version is `#{::Dip.config.version}`"
      error!(msg, code: VERSION_MISSMATCH_EXIT_CODE)
    end
  end
end
