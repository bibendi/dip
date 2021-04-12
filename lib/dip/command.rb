# frozen_string_literal: true

require "forwardable"

module Dip
  class Command
    extend Forwardable

    def_delegators self, :shell, :subshell

    class ExecRunner
      def self.call(cmdline, env: {}, **options)
        ::Process.exec(env, cmdline, options)
      end
    end

    class SubshellRunner
      def self.call(cmdline, env: {}, panic: true, **options)
        return if ::Kernel.system(env, cmdline, options)
        raise Dip::Error, "Command '#{cmdline}' executed with error." if panic
      end
    end

    class << self
      def shell(cmd, argv = [], subshell: false, **options)
        cmd = Dip.env.interpolate(cmd)
        argv = [argv] if argv.is_a?(String)
        argv = argv.map { |arg| Dip.env.interpolate(arg) }
        cmdline = [cmd, *argv].compact.join(" ").strip

        puts [Dip.env.vars, cmdline].inspect if Dip.debug?

        runner = subshell ? SubshellRunner : ExecRunner
        runner.call(cmdline, env: Dip.env.vars, **options)
      end

      def subshell(*args, **kwargs)
        kwargs[:subshell] = true
        shell(*args, **kwargs)
      end
    end
  end
end
