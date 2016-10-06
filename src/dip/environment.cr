module Dip
  class Environment
    def initialize(environment : Hash(String, String))
      @vars = Hash(String, String).new

      environment.each do |key, value|
        @vars[key] = ENV.fetch(key, value)
      end
    end

    def vars
      @vars
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
