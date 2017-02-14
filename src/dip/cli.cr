module Dip
  class Cli < ::Cli::Supercommand
    command_name "dip"

    command "compose"
    command "run"
    command "ssh"
    command "dns"
    command "provision"
    command "completion"
    command "version"

    class Options
      help
    end

    class Help
      header <<-EOS
        Docker Interaction Process

        CLI utility for straightforward provisioning and interacting with application configured by docker-compose.
      EOS

      footer "https://github.com/bibendi/dip"
    end
  end
end

require "./commands/*"
