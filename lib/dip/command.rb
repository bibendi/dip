# frozen_string_literal: true

require "forwardable"

module Dip
  class Command
    extend Forwardable

    def_delegators self, :shell, :subshell

    class ExecRunner
      def self.call(cmd, argv, env: {}, **options)
        ::Process.exec(env, cmd, *argv, options)
      end
    end

    class SubshellRunner
      def self.call(cmd, argv, env: {}, panic: true, **options)
        return if ::Kernel.system(env, cmd, *argv, options)
        raise Dip::Error, "Command '#{([cmd] + argv).join(' ')}' executed with error." if panic
      end
    end

    class << self
      def shell(cmd, argv = [], subshell: false, **options)
        cmd = Dip.env.interpolate(cmd)
        argv = argv.map { |arg| Dip.env.interpolate(arg) }

        puts [Dip.env.vars, cmd, argv].inspect if Dip.debug?

        runner = subshell ? SubshellRunner : ExecRunner
        runner.call(cmd, argv, env: Dip.env.vars, **options)
      end

      def subshell(*args, **kwargs)
        kwargs[:subshell] = true
        shell(*args, **kwargs)
      end
    end
  end
end
