require "../config_command"

module Dip::Cli::Commands
  class Provision < ::Dip::ConfigCommand
    #class Options
      #help
    #end

    class Help
      caption "Execute commands within provision section"
    end

    def run
      commands = ::Dip.config.provision
      if commands.is_a?(Array)
        commands.each do |command|
          exec_cmd!(command)
        end
      end
    end
  end
end
