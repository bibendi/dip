module Dip
  class Cli < ::Cli::Supercommand
    command "compose"
    command "ssh"
    command "dns"
    command "provision"
    command "version"

    class Options
      help
    end
  end
end

require "./commands/*"
