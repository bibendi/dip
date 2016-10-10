require "../command"

module Dip::Cli::Commands
  class Run < ::Dip::Command
    class Options
      arg "cmd"
      arg "subcmd", stop: true, default: ""
      help
    end

    class Help
      caption "Run configured command in a service"
    end

    @config : Hash(String, ::Dip::Config::Command) | Nil

    def initialize(*args)
      super
      @config = ::Dip.config.interaction
    end

    def run
      return unless (config = @config)

      command = config[args.cmd]

      if subcommands = command.subcommands
        subcommand = subcommands[args.subcmd]
        service_arg = subcommand.service || command.service
        cmd_arg = subcommand.command
      else
        service_arg = command.service
        cmd_arg = "#{command.command} #{args.subcmd}".strip
      end

      cmd_options = unparsed_args || %w()

      exec! "dip compose run --rm #{service_arg} #{cmd_arg} #{cmd_options.join " "}".strip
    end
  end
end
