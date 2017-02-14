require "../command"

module Dip::Cli::Commands
  class Completion < ::Cli::Supercommand
    command "bash"
    command "zsh"

    class Options
      help
    end

    class Help
      caption "Generate completion scripts"
    end

    module Commands
      class Bash < ::Dip::Command
        def run
          puts ::Dip::Cli.generate_bash_completion
        end
      end

      class Zsh < ::Dip::Command
        def run
          puts ::Dip::Cli.generate_zsh_completion
        end
      end
    end
  end
end
