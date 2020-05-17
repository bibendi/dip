# frozen_string_literal: true

require 'pathname'

require_relative '../command'
require_relative 'dns'

module Dip
  module Commands
    class Compose < Dip::Command
      DOCKER_EMBEDDED_DNS = "127.0.0.11"

      attr_reader :argv, :config

      def initialize(*argv)
        @argv = argv
        @config = ::Dip.config.compose || {}
      end

      def execute
        Dip.env["DIP_DNS"] ||= find_dns

        compose_argv = Array(find_files) + Array(cli_options) + argv

        shell("docker-compose", compose_argv)
      end

      private

      def find_files
        return unless (files = config[:files])

        if files.is_a?(Array)
          files.each_with_object([]) do |file_path, memo|
            file_path = ::Dip.env.interpolate(file_path)
            file_path = Pathname.new(file_path)
            file_path = Dip.config.file_path.parent.join(file_path).expand_path if file_path.relative?
            next unless file_path.exist?

            memo << "--file"
            memo << file_path.to_s
          end
        end
      end

      def cli_options
        %i[project_name project_directory].flat_map do |name|
          next unless (value = config[name])
          next unless value.is_a?(String)

          value = ::Dip.env.interpolate(value)
          ["--#{name.to_s.gsub('_', '-')}", value]
        end.compact
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
