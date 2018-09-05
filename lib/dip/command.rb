# frozen_string_literal: true

module Dip
  class Command
    def self.exec(cmd, *argv)
      cmd = ::Dip.env.replace(cmd)
      argv = argv.map { |arg| ::Dip.env.replace(arg) }

      puts [Dip.env.vars, cmd, argv].inspect if Dip.debug?

      ::Process.exec(Dip.env.vars, cmd, *argv)
    end
  end
end
