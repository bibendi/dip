# frozen_string_literal: true

require_relative "../command"

module Dip
  module Commands
    class Preflight < Dip::Command
      def execute
        Dip.config.preflight.each do |command|
          exec_subprocess(command)
        end
      end
    end
  end
end
