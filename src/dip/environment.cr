module Dip
  class Environment
    property vars = Hash(String, String).new
    property hard_vars = Hash(String, String).new

    def initialize(default_vars : Hash(String, String | Bool | Int64 | Float64 | String | Time))
      default_vars.each do |key, value|
        vars[key] = ENV.fetch(key) { replace(value.to_s) }
      end

      unless Dip.test?
        vars["DIP_DNS"] = ENV.fetch("DIP_DNS") { find_dns }
      end
    end

    def merge!(new_vars : Hash(String, String | Bool | Int64 | Float64 | String | Time))
      new_vars.each do |key, value|
        vars[key] = replace(value.to_s)
      end
    end

    def replace(value : String)
      result = value.dup

      vars.each do |key, value|
        result = result.gsub("$#{key}", value)
        result = result.gsub("${#{key}}", value)
      end

      result
    end

    private def find_dns
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
