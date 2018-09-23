# frozen_string_literal: true

require_relative '../command'
require_relative 'dns'

module Dip
  module Commands
    class Compose < Dip::Command
      DOCKER_EMBEDDED_DNS = "127.0.0.11"

      def initialize(cmd, argv = [])
        @cmd = cmd
        @argv = argv
        @config = ::Dip.config.compose
      end

      def execute
        compose_argv = Array(find_files) + Array(find_project_name)
        compose_argv << @cmd
        compose_argv += @argv

        Dip.env["DIP_DNS"] ||= find_dns

        shell("docker-compose", compose_argv)
      end

      private

      def find_files
        return unless (files = @config[:files])

        if files.is_a?(Array)
          result = files.each_with_object([]) do |file_name, memo|
            file_name = ::Dip.env.interpolate(file_name)
            next unless File.exist?(file_name)
            memo << "--file"
            memo << file_name
          end
        end
      end

      def find_project_name
        return unless (project_name = @config[:project_name])

        if project_name.is_a?(String)
          project_name = ::Dip.env.interpolate(project_name)
          ["--project-name", project_name]
        end
      end

      def find_dns
        name = Dip.env["DNSDOCK_CONTAINER"] || "dnsdock"
        net = Dip.env["FRONTEND_NETWORK"] || "frontend"

        IO.pipe do |r, w|
          Dip::Commands::DNS::IP.
            new(name: name, net: net).
            execute(out: w, err: File::NULL, panic: false)

          w.close_write
          ip = r.readlines[0].to_s.strip
          ip.empty? ? DOCKER_EMBEDDED_DNS : ip
        end
      end
    end
  end
end
