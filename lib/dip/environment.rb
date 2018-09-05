# frozen_string_literal: true

module Dip
  class Environment
    VAR_REGEX = /\$[\{]?(?<var_name>[a-zA-Z_][a-zA-Z0-9_]*)[\}]?/

    attr_reader :vars

    def initialize(default_vars)
      @vars = {}

      merge(default_vars)

      fill_special_vars
    end

    def merge(new_vars)
      new_vars.each do |key, value|
        @vars[key] = ENV.fetch(key) { replace(value.to_s) }
      end
    end

    def [](name)
      vars.fetch(name) { ENV[name] }
    end

    def interpolate(value)
      value.gsub(VAR_REGEX) do
        var_name = Regexp.last_match[:var_name]
        self[var_name]
      end
    end

    alias replace interpolate

    private

    # :nocov:
    # TODO: [Refactor] Move to the more suitable place.
    def fill_special_vars
      if @vars.key?("DIP_DNS") && (dip_dns = @vars["DIP_DNS"]).empty?
        @vars["DIP_DNS"] = find_dns # no
      end

      if @vars.key?("DIP_OS") && (dip_os = @vars["DIP_OS"]).empty?
        @vars["DIP_OS"] = find_os_name
      end
    end

    def find_os_name
      Gem::Platform.local.os
    end

    def find_dns
      dns_net = self["FRONTEND_NETWORK"] || "frontend"
      dns_name = self["DNSDOCK_CONTAINER"] || "dnsdock"

      cmd = "docker inspect" \
            " --format '{{ .NetworkSettings.Networks.#{dns_net}.IPAddress }}'" \
            " #{dns_name} 2>/dev/null"
      ip = `#{cmd}`.strip

      if ip.empty?
        "8.8.8.8"
      else
        ip
      end
    end
    # :nocov:
  end
end
