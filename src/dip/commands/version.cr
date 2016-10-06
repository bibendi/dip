require "../command"

module Dip::Cli::Commands
  class Version < ::Dip::Command
    class Options
      help
    end

    def run
      puts ::Dip::VERSION
    end
  end
end
