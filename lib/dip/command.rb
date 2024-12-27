# frozen_string_literal: true

require "forwardable"

module Dip
  class Command
    extend Forwardable

    def_delegators self, :exec_program, :exec_subprocess

    class ProgramRunner
      def self.call(cmdline, env: {}, **options)
        puts "Dip.Command.ProgramRunner >>>>>>>>>>"
        puts "cmdline: #{cmdline}"
        if cmdline.is_a?(Array)
          ::Kernel.exec(env, cmdline[0], *cmdline.drop(1), **options)
        else
          ::Kernel.exec(env, cmdline, **options)
        end
      end
    end

    class SubprocessRunner
      def self.call(cmdline, env: {}, panic: true, **options)
        status = ::Kernel.system(env, cmdline, **options)

        if !status && panic
          raise Dip::Error, "Command '#{cmdline}' executed with error"
        else
          status
        end
      end
    end

    class << self
      def exec_program(*args, **kwargs)
        run(ProgramRunner, *args, **kwargs)
      end

      def exec_subprocess(*args, **kwargs)
        run(SubprocessRunner, *args, **kwargs)
      end

      private

      def run(runner, cmd, argv = [], shell: true, **options)
        cmd = Dip.env.interpolate(cmd)
        argv = [argv] if argv.is_a?(String)
        argv = argv.map { |arg| Dip.env.interpolate(arg) }
        cmdline = [cmd, *argv].compact
        cmdline = cmdline.join(" ").strip if shell

        puts [Dip.env.vars, cmdline].inspect if Dip.debug?

        runner.call(cmdline, env: Dip.env.vars, **options)
      end
    end
  end
end
