# frozen_string_literal: true

require "fileutils"

module Dip
  module Commands
    module Infra
      class Service
        attr_reader :name, :git, :ref, :location, :project_name, :network_name, :network_env_var

        def initialize(name, git: nil, ref: nil, path: nil)
          if git.nil? && path.nil?
            raise ArgumentError, "Infra service `#{name}` configuration error: git or path must be defined"
          end

          @name = name
          @git = git
          @ref = ref || "latest"
          @location = if git
            "#{Dip.home_path}/infra/#{@name}/#{@ref}"
          else
            File.expand_path(path)
          end
          @project_name = "dip-infra-#{name}-#{@ref}"
          @network_name = "dip-net-#{name}-#{@ref}"
          @network_env_var = "DIP_INFRA_NETWORK_#{@name.to_s.upcase.tr("-", "_")}"
        end

        def env
          {
            "COMPOSE_PROJECT_NAME" => project_name,
            "DIP_INFRA_NETWORK_NAME" => network_name
          }
        end
      end
    end
  end
end
