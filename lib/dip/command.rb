# frozen_string_literal: true

require 'tty-command'

module Dip
  class Command
    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # The external commands runner
    #
    # @see http://www.rubydoc.info/gems/tty-command
    #
    # @api public
    def command(cmd, *argv, verbose: false, printer: :quiet, **options)
      cmd = ::Dip.env.replace(cmd)
      argv = argv.map { |arg| ::Dip.env.replace(arg) }

      TTY::Command.new(verbose: verbose,
                       printer: printer,
                       dry_run: Dip.env.test? || Dip.env.debug?,
                       **options)
                  .run(Dip.env.vars, cmd, *argv)
    end
  end
end
