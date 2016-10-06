module Dip
  class Cli < ::Cli::Supercommand
    command "compose"
    command "ssh"
    command "dns"

    class Options
      help
    end
  end
end

require "./commands/*"
