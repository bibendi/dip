module Dip
  class Command < ::Cli::Command
    def exec!(command : String, argv = nil)
      command = "#{command} #{argv.join(' ')}" if argv.is_a?(Array)

      command = ::Dip.env.replace(command)

      puts command.inspect if debug?

      status = ::Process.run(command, env: Dip.env.vars, shell: true, input: true, output: true, error: true)

      error!(code: status.exit_code) unless status.success?
    end

    def debug?
      ENV["DIP_DEBUG"]? && %w(true 1 yes y).includes?(ENV["DIP_DEBUG"]?)
    end
  end
end
