# frozen_string_literal: true

require_relative "../command"

module Dip
  module Commands
    class DownAll < Dip::Command
      def execute
        exec_subprocess(
          "docker rm --volumes $(docker stop $(docker ps --filter 'label=com.docker.compose.project' -q))"
        )
      end
    end
  end
end
