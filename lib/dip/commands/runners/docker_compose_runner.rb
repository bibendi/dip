# frozen_string_literal: true

require_relative "base"
require_relative "../compose"

module Dip
  module Commands
    module Runners
      class DockerComposeRunner < Base
        def execute
          Commands::Compose.new(
            command[:compose][:method],
            *compose_arguments,
            shell: command[:shell]
          ).execute
        end

        private

        def compose_arguments
          compose_argv = command[:compose][:run_options].dup

          if command[:compose][:method] == "run"
            compose_argv.concat(run_vars)
            compose_argv.concat(published_ports)
            compose_argv << "--rm"
          end

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
      end
    end
  end
end
