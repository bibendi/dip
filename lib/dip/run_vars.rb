# frozen_string_literal: true

module Dip
  class RunVars
    attr_reader :argv, :env

    class << self
      attr_accessor :env

      def call(*args)
        new(*args).call
      end
    end

    self.env = {}

    def initialize(argv, env = ENV)
      @argv = argv
      @env = env

      self.class.env.clear
    end

    def call
      populate_env_vars
      parse_argv
    end

    private

    def populate_env_vars
      return if early_envs.empty?

      (env.keys - early_envs).each do |key|
        next if env_excluded?(key)

        self.class.env[key] = env[key]
      end
    end

    def parse_argv
      stop_parse = false

      argv.each_with_object([]) do |arg, memo|
        if !stop_parse && arg.include?("=")
          key, val = arg.split("=", 2)
          self.class.env[key] = val
        else
          memo << arg
          stop_parse ||= true
        end
      end
    end

    def early_envs
      @early_envs ||= env["DIP_EARLY_ENVS"].to_s.split(",")
    end

    def env_excluded?(key)
      key.start_with?("DIP_", "_")
    end
  end
end
