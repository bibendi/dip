# frozen_string_literal: true

module Dip
  class Environment
    attr_reader :vars, :run_vars

    def initialize(vars)
      @vars = {}

      vars.each do |key, value|
        @vars[key] = ENV.fetch(key) { replace(value.to_s) }
      end

      return if test?
      @vars["DIP_DNS"] = ENV.fetch("DIP_DNS") { find_dns }
    end

    def test?
      ENV["DIP_ENV"] == "test"
    end

    def debug?
      ENV["DIP_ENV"] == "debug"
    end

    def merge!(new_vars)
      new_vars.each do |key, value|
        @vars[key] = replace(value.to_s)
      end
    end

    def replace(value)
      result = value.dup

      @vars.each do |key, value|
        result = result.
          gsub("$#{key}", value).
          gsub("${#{key}}", value)
      end

      result
    end

    private

    def find_dns
      dns_net = ENV.fetch("FRONTEND_NETWORK") { "frontend" }
      dns_name = ENV.fetch("DNSDOCK_CONTAINER") { "dnsdock" }
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
  end
end
