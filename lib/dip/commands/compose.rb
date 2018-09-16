# frozen_string_literal: true

require_relative '../command'

module Dip
  module Commands
    class Compose < Dip::Command
      def initialize(cmd, argv = [])
        @cmd = cmd
        @argv = argv
        @config = ::Dip.config.compose
      end

      def execute
        compose_argv = Array(find_files) + Array(find_project_name)
        compose_argv << @cmd
        compose_argv += @argv

        shell("docker-compose", compose_argv)
      end

      private

      def find_files
        return unless (files = @config[:files])

        if files.is_a?(Array)
          result = files.each_with_object([]) do |file_name, memo|
            file_name = ::Dip.env.replace(file_name)
            next unless File.exist?(file_name)
            memo << "--file"
            memo << file_name
          end
        end
      end

      def find_project_name
        return unless (project_name = @config[:project_name])

        if project_name.is_a?(String)
          project_name = ::Dip.env.replace(project_name)
          ["--project-name", project_name]
        end
      end
    end
  end
end
