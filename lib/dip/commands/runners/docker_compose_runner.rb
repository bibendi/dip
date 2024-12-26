# frozen_string_literal: true

require_relative "base"
require_relative "../compose"

module Dip
  module Commands
    module Runners
      class DockerComposeRunner < Base
        def execute
          Commands::Compose.new(
            *compose_profiles,
            command[:compose][:method],
            *compose_arguments,
            shell: command[:shell]
          ).execute
        end

        private

        def compose_profiles
          return [] if command[:compose][:profiles].empty?

          update_command_for_profiles

          command[:compose][:profiles].each_with_object([]) do |profile, argv|
            argv.concat(["--profile", profile])
          end
        end

        def compose_arguments
          compose_argv = command[:compose][:run_options].dup

          if command[:compose][:method] == "run"
            compose_argv.concat(run_vars)
            compose_argv.concat(published_ports)
            compose_argv << "--rm"
          end

          compose_argv << "--user #{command.fetch(:user)}" if command[:user]
          compose_argv << "--workdir #{command.fetch(:workdir)}" if command[:workdir]

          compose_argv << command.fetch(:service)

          unless (cmd = command[:command]).empty?
            if command[:shell]
              compose_argv << cmd
            else
              compose_argv.concat(cmd.shellsplit)
            end
          end

          compose_argv.concat(command_args)

          compose_argv
        end

        def run_vars
          run_vars = Dip::RunVars.env
          return [] unless run_vars

          run_vars.map { |k, v| ["-e", "#{k}=#{Shellwords.escape(v)}"] }.flatten
        end

        def published_ports
          publish = options[:publish]

          if publish.respond_to?(:each)
            publish.map { |p| "--publish=#{p}" }
          else
            []
          end
        end

        def update_command_for_profiles
          # NOTE: When using profiles, the method is always `up`.
          #       This is because `docker compose` does not support profiles
          #       for other commands. Also, run options need to be removed
          #       because they are not supported by `up`.
          command[:compose][:method] = "up"
          command[:command] = ""
          command[:compose][:run_options] = []
        end
      end
    end
  end
end
