# frozen_string_literal: true

module Dip
  class CLI
    class Base < Thor
      def self.exit_on_failure?
        true
      end
    end
  end
end
