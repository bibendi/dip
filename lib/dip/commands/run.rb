# frozen_string_literal: true

require "shellwords"
require_relative "../../../lib/dip/run_vars"
require_relative "../command"
require_relative "../interaction_tree"
require_relative "runners/local_runner"
require_relative "runners/docker_compose_runner"
require_relative "runners/kubectl_runner"

require_relative "kubectl"

module Dip
  module Commands
    class Run < Dip::Command
      def initialize(cmd, *argv, **options)
        @options = options

        @command, @argv = InteractionTree
          .new(Dip.config.interaction)
          .find(cmd, *argv)&.values_at(:command, :argv)

        raise Dip::Error, "Command `#{[cmd, *argv].join(" ")}` not recognized!" unless command

        Dip.env.merge(command[:environment])
      end

      def execute
        lookup_runner
          .new(command, argv, **options)
          .execute
      end

      private

      attr_reader :command, :argv, :options

      def lookup_runner
        # if debug mode
        puts "Dip.Commands.Run#lookup_runner command: #{command}"
        if (runner = command[:runner])
          camelized_runner = runner.split("_").collect(&:capitalize).join
          Runners.const_get("#{camelized_runner}Runner")
        elsif command[:service]
          Runners::DockerComposeRunner
        elsif command[:pod]
          Runners::KubectlRunner
        else
          Runners::LocalRunner
        end
      end
    end
  end
end
