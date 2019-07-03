# frozen_string_literal: true

require "dip/config"
require "dip/environment"

module Dip
  Error = Class.new(StandardError)

  class << self
    def config
      @config ||= Dip::Config.new
    end

    def env
      @env ||= Dip::Environment.new(Dip::Config.exist? ? config.environment : {})
    end

    def bin_path
      $PROGRAM_NAME.start_with?("./") ? File.expand_path($PROGRAM_NAME) : "dip"
    end

    %w(test debug).each do |key|
      define_method("#{key}?") do
        ENV["DIP_ENV"] == key
      end
    end

    def reset!
      @config = nil
      @env = nil
    end
  end
end
