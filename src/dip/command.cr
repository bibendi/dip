module Dip
  class Command < ::Cli::Command
    def exec!(command : String, argv = nil)
      command = "#{command} #{argv.join(' ')}" if argv.is_a?(Array)

      puts command.inspect if ENV["DIP_DEBUG"]?

      system(command) || error!(code: $?.exit_code)
    end
  end
end
