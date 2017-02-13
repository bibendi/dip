require "../command"

module Dip::Cli::Commands
  class Version < ::Dip::Command
    #class Options
      #help
    #end

    class Help
      caption "Show the DIP version information"
    end

    def run
      puts ::Dip::VERSION
    end
  end
end
