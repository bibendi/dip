module Dip
  class Command < ::Cli::Command
    def exec_cmd!(command : String, argv = nil)
      status = exec_cmd(command, argv)
      error!(code: status.exit_code) if status && !status.success?
    end

    def exec_cmd(command : String, argv = nil)
      command = "#{command} #{argv.join(' ')}" if argv.is_a?(Array)
      command = ::Dip.env.replace(command)

      puts command.inspect if Dip.debug?

      if Dip.test?
        puts command
      else
        ::Process.run(command, env: Dip.env.vars, shell: true, input: STDIN, output: STDOUT, error: STDERR)
      end
    end
  end
end
