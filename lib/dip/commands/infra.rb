# frozen_string_literal: true

require "shellwords"
require "fileutils"
require_relative "../command"

module Dip
  module Commands
    module Infra
      class Update < Dip::Command
        def initialize(service:)
          @service = service
        end

        def execute
          return unless @service.git

          if Dir.exist?(@service.location)
            pull
          else
            clone
          end
        end

        private

        def pull
          Dir.chdir(@service.location) do
            exec_subprocess("git", "checkout .")
            exec_subprocess("git", "pull --rebase")
          end
        end

        def clone
          FileUtils.mkdir_p(@service.location)

          Dir.chdir(@service.location) do
            args = [
              "clone",
              "--single-branch",
              "--depth 1",
              "--branch #{Shellwords.escape(@service.ref)}",
              Shellwords.escape(@service.git),
              Shellwords.escape(@service.location)
            ]
            exec_subprocess("git", args)
          end
        end
      end

      class Up < Dip::Command
        def initialize(*compose_argv, service:)
          @compose_argv = compose_argv.compact
          @service = service
        end

        def execute
          Dir.chdir(@service.location) do
            exec_subprocess("docker", "network create #{@service.network_name}", panic: false, err: File::NULL)

            argv = %w[compose up --detach] + @compose_argv
            exec_subprocess("docker", argv, env: @service.env)
          end
        end
      end

      class Down < Dip::Command
        def initialize(*compose_argv, service:)
          @compose_argv = compose_argv.compact
          @service = service
        end

        def execute
          Dir.chdir(@service.location) do
            argv = %w[compose down] + @compose_argv
            exec_subprocess("docker", argv, env: @service.env)
          end
        end
      end
    end
  end
end
