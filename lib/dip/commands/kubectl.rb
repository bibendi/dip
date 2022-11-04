# frozen_string_literal: true

require_relative "../command"

module Dip
  module Commands
    class Kubectl < Dip::Command
      attr_reader :argv, :config

      def initialize(*argv)
        @argv = argv
        @config = ::Dip.config.kubectl || {}
      end

      def execute
        k_argv = cli_options + argv

        exec_program("kubectl", k_argv)
      end

      private

      def cli_options
        %i[namespace].flat_map do |name|
          next unless (value = config[name])
          next unless value.is_a?(String)

          value = ::Dip.env.interpolate(value).delete_suffix("-")
          ["--#{name.to_s.tr("_", "-")}", value]
        end.compact
      end
    end
  end
end
