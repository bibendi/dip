module Dip
  class Command < ::Cli::Command
    def exec_cmd!(command : String, argv = nil)
      status = exec_cmd(command, argv)
      error!(code: status.exit_code) unless status.success?
    end

    def exec_cmd(command : String, argv = nil)
      command = "#{command} #{argv.join(' ')}" if argv.is_a?(Array)
      command = ::Dip.env.replace(command)

      puts command.inspect if debug?

      ::Process.run(command, env: Dip.env.vars, shell: true, input: true, output: true, error: true)
    end

    def debug?
      ENV["DIP_DEBUG"]? && %w(true 1 yes y).includes?(ENV["DIP_DEBUG"]?)
    end
  end
end
