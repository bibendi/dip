# frozen_string_literal: true

module Dip
  class Command
    class ExecRunner
      def self.call(cmd, *argv, env: {})
        ::Process.exec(env, cmd, *argv)
      end
    end

    class SubshellRunner
      def self.call(cmd, *argv, env: {})
        ::Kernel.system(env, cmd, *argv)
      end
    end

    class << self
      def run(cmd, *argv, subshell: false)
        cmd = Dip.env.interpolate(cmd)
        argv = argv.map { |arg| Dip.env.interpolate(arg) }

        puts [Dip.env.vars, cmd, argv].inspect if Dip.debug?

        runner = subshell ? SubshellRunner : ExecRunner
        return if runner.call(Dip.env.vars, cmd, *argv)
        raise Dip::Error, "Command '#{cmd}' executed with error."
      end
    end
  end
end
