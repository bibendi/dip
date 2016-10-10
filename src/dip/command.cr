module Dip
  class Command < ::Cli::Command
    def exec!(command : String, argv = nil)
      command = "#{command} #{argv.join(' ')}" if argv.is_a?(Array)

      puts command.inspect if debug?

      system(command) || error!(code: $?.exit_code)
    end

    def debug?
      ENV["DIP_DEBUG"]? && %w(true 1 yes y).includes?(ENV["DIP_DEBUG"]?)
    end
  end
end
