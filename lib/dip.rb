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
      @env ||= Dip::Environment.new(config.exist? ? config.environment : {})
    end

    def bin_path
      # TODO: Maybe there's a better way?
      $PROGRAM_NAME.start_with?("./") ? File.expand_path($PROGRAM_NAME) : $PROGRAM_NAME
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
