module Dip
  class Environment
    getter vars

    def initialize(default_vars : Hash(String, String))
      @vars = Hash(String, String).new

      default_vars.each do |key, value|
        @vars[key] = ENV.fetch(key) { replace(value) }
      end
    end

    def merge!(new_vars : Hash(String, String))
      new_vars.each do |key, value|
        @vars[key] = replace(value)
      end
    end

    def replace(value : String)
      result = value.dup

      @vars.each do |key, value|
        result = result.gsub("$#{key}", value)
        result = result.gsub("${#{key}}", value)
      end

      result
    end
  end
end
