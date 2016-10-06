module Dip
  class Command < ::Cli::Command
    def exec!(command : String, argv = nil)
      system(command, argv) || error!(code: $?.exit_code)
    end
  end
end
