# frozen_string_literal: true

module Dip
  class RunVars
    attr_reader :argv, :env, :early_envs, :env_vars, :result_argv

    def self.call(*args)
      new(*args).call
    end

    def initialize(argv, env = ENV)
      @argv = argv
      @env = env
      @env_vars = {}
      @result_argv = []
    end

    def call
      extract_new_env_vars
      extract_passed_env_vars

      result_argv.push(*argv_env_vars) unless env_vars.empty?

      result_argv
    end

    private

    def extract_new_env_vars
      early_envs = env['DIP_EARLY_ENVS'].to_s
      return if early_envs.empty?

      (env.keys - early_envs.split(',')).each do |key|
        next if key.start_with?("DIP_")

        env_vars[key] = env[key]
      end
    end

    def extract_passed_env_vars
      stop_parse = false

      argv.each do |arg|
        if !stop_parse && arg.include?("=")
          key, val = arg.split("=", 2)
          env_vars[key] = val
        else
          result_argv << arg
          stop_parse ||= true
        end
      end
    end

    def argv_env_vars
      result = env_vars.map { |key, val| "#{key}:#{val}" }
      result[0] = "--x-dip-run-vars=#{result[0]}"

      result
    end
  end
end
