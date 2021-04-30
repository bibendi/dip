# frozen_string_literal: true

require_relative "../command"

module Dip
  module Commands
    class Provision < Dip::Command
      def execute
        Dip.config.provision.each do |command|
          exec_subprocess(command)
        end
      end
    end
  end
end
