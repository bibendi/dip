# frozen_string_literal: true

module Dip
  class Environment
    VAR_REGEX = /\$[\{]?(?<var_name>[a-zA-Z_][a-zA-Z0-9_]*)[\}]?/
    SPECIAL_VARS = {"DIP_OS" => :find_dip_os}.freeze

    attr_reader :vars

    def initialize(default_vars)
      @vars = {}

      merge(default_vars)
    end

    def merge(new_vars)
      new_vars.each do |key, value|
        @vars[key] = ENV.fetch(key) { replace(value.to_s) }
      end
    end

    def [](name)
      vars.fetch(name) { ENV[name] }
    end

    def []=(key, value)
      @vars[key] = value
    end

    def interpolate(value)
      value.gsub(VAR_REGEX) do
        var_name = Regexp.last_match[:var_name]

        if SPECIAL_VARS.key?(var_name)
          self[var_name] || send(SPECIAL_VARS[var_name])
        else
          self[var_name]
        end
      end
    end

    alias replace interpolate

    private

    def find_dip_os
      @dip_os ||= Gem::Platform.local.os
    end
  end
end
