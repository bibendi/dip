# frozen_string_literal: true

require_relative "base"
require_relative "../kubectl"

module Dip
  module Commands
    module Runners
      class KubectlRunner < Base
        def execute
          Commands::Kubectl.new(*kubectl_arguments).execute
        end

        private

        def kubectl_arguments
          argv = ["exec", "--tty", "--stdin"]

          pod, container = command.fetch(:pod).split(":")
          argv.push("--container", container) unless container.nil?
          argv.push(pod, "--")

          unless (entrypoint = command[:entrypoint]).nil?
            argv << entrypoint
          end
          argv << command.fetch(:command)
          argv.concat(command_args)

          argv
        end
      end
    end
  end
end
