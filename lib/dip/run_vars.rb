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

    def initialize(argv, env = ENV)
      @argv = argv
      @env = env
      self.class.env = {}
    end

    def call
      extract_new_env_vars

      stop_parse = false
      result_argv = []

      argv.each do |arg|
        if !stop_parse && arg.include?("=")
          key, val = arg.split("=", 2)
          self.class.env[key] = val
        else
          result_argv << arg
          stop_parse ||= true
        end
      end

      result_argv
    end

    private

    def extract_new_env_vars
      early_envs = env['DIP_EARLY_ENVS'].to_s
      return if early_envs.empty?

      (env.keys - early_envs.split(',')).each do |key|
        next if key.start_with?("DIP_") || key.start_with?("_")

        self.class.env[key] = env[key]
      end
    end
  end
end
