require "../command"

module Dip::Cli::Commands
  class Provision < ::Dip::Command
    class Options
      help
    end

    class Help
      caption "Execute commands within provision section"
    end

    def run
      commands = ::Dip.config.provision
      if commands.is_a?(Array)
        commands.each do |command|
          exec! ::Dip.env.replace(command)
        end
      end
    end
  end
end
